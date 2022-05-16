pragma solidity >= 0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IApePair.sol";
import "./interfaces/IUniswapV2Router02.sol";

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Arbitrage is Ownable {
    using SafeMath for uint256;
    IERC20 public baseToken = IERC20(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c); // wbnb

    mapping(address => uint256) public routerFees;

    constructor() {
        routerFees[0x10ED43C718714eb63d5aA57B78B54704E256024E] = 9975;
        routerFees[0xcF0feBd3f17CEf5b47b0cD257aCf6025c5BFf3b7] = 9980;
        routerFees[0x325E343f1dE602396E256B67eFd1F61C3A6B38Bd] = 9970;
    }
    function exec() public onlyOwner isProfit {
        
    }
    
    function execute(IApePair[] memory _pairs, bool[] memory _directions, IUniswapV2Router02[] memory _routers, address[] memory _tokens, uint256 _amount) public onlyOwner isProfit {
        require(baseToken.balanceOf(address(this)) >= _amount, "Initial amount not enough");
        require(_pairs.length == _routers.length, "Sanity fail");
        require(_pairs.length == _directions.length, "Sanity2 fail");
        // pair is pair list.
        // _amount is start amount
        uint256 currentAmount = _amount;
        for(uint i = 0; i < _pairs.length; i++) {
            IApePair pair = _pairs[i];
            if(i == 0) {
                // the first path
                address[] memory path = pathMaker(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c, _tokens[0]);
                IUniswapV2Router02 router = _routers[0];
                uint256[] memory outputs = router.getAmountsOut(currentAmount, path);
                if(_directions[0]) {
                    baseToken.transfer(address(pair), currentAmount);
                    pair.swap(0, outputs[1], address(this), bytes(''));
                } 
            }
            pair.skim(address(this)); // skim for check if outamount is low
        }
    }

    function pathMaker(address _i, address _j) internal returns(address[] memory) {
        address[] memory path = new address[](2);
        path[0] = _i;
        path[1] = _j;
        return path;
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