pragma solidity >= 0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IApePair.sol";
import "./interfaces/IUniswapV2Router02.sol";

contract Arbitrage is Ownable {

    IERC20 public baseToken = IERC20(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c); // wbnb
    
    function execute(IApePair[] memory _pairs, uint256[] memory _outAmounts, bool[] memory _directions, uint256 _amount) public onlyOwner isProfit {
        require(baseToken.balanceOf(address(this)) >= _amount, "Initial amount not enough");
        require(_pairs.length == _outAmounts.length, "Sanity fail");
        require(_pairs.length == _directions.length, "Sanity2 fail");
        // pair is pair list.
        // _amount is start amount
        for(uint i = 0; i < _pairs.length; i++) {
            IApePair pair = _pairs[i];
            if(i == 0) {
                // on first iteration we send base token directly
                baseToken.transfer(address(pair), _amount);
            }
            if(i + 1 == _pairs.length) {
                // last iteration
                if(_directions[i]) {
                    // true 0 -> 1
                    pair.swap(0, _outAmounts[i], address(this), abi.encode(""));
                } else {
                    // false 1 -> 0
                    pair.swap(_outAmounts[i], 0, address(this), abi.encode(""));
                }
            } else {
                if(_directions[i]) {
                    // true 0 -> 1
                    pair.swap(0, _outAmounts[i], address(_pairs[i+1]), abi.encode(""));
                } else {
                    // false 1 -> 0
                    pair.swap(_outAmounts[i], 0, address(_pairs[i+1]), abi.encode(""));
                }
            }
            pair.skim(address(this)); // skim for check if outamount is low
        }
    }

    function executeManuel(IApePair _pair, uint256 _start, uint256 _output) public onlyOwner {
        baseToken.transfer(address(_pair), _start);
        _pair.swap(0, _output, address(this), abi.encode(""));
    }

    function manuelApprove(IERC20 token, address spender, uint256 amount) public onlyOwner {
        token.approve(spender, amount);
    }

    function executeWithRouter(IUniswapV2Router02[] memory _routers, address[] memory _paths, uint256 _amount) public onlyOwner {
        for(uint i = 0; i < _routers.length; i++) {
            IUniswapV2Router02 router = _routers[i];
            if(i == 0) {
                address[] memory path = new address[](2);
                path[0] = _paths[0];
                path[1] = _paths[1];
                baseToken.approve(address(router), _amount);
                router.swapExactTokensForTokensSupportingFeeOnTransferTokens(_amount, 0, path, address(this), block.timestamp);
            } else if(i == 1) {
                address[] memory path = new address[](2);
                path[0] = _paths[i];
                path[1] = _paths[i + 1];
                IERC20 token = IERC20(_paths[i]);
                uint256 balance = token.balanceOf(address(this));
                token.approve(address(router), balance);
                router.swapExactTokensForTokensSupportingFeeOnTransferTokens(balance, 0, path, address(this), block.timestamp);
            } else {
                // last
                address[] memory path = new address[](2);
                path[0] = _paths[i];
                path[1] = _paths[0];
                IERC20 token = IERC20(_paths[i]);
                uint256 balance = token.balanceOf(address(this));
                token.approve(address(router), balance);
                router.swapExactTokensForTokensSupportingFeeOnTransferTokens(balance, 0, path, address(this), block.timestamp);
            }
        }
    }


    function withdraw(IERC20 token, uint256 amount) public onlyOwner {
        token.transfer(msg.sender, amount);
    }

    modifier isProfit {
        uint256 balance = baseToken.balanceOf(address(this));
        _;
        uint256 balanceAfter = baseToken.balanceOf(address(this));
        require(balanceAfter >= balance, "No profit");
    }
    
}