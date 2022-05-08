pragma solidity >= 0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IApePair.sol";
import "./interfaces/IUniswapV2Router02.sol";

contract Arbitrage is Ownable {

    IERC20 public baseToken = IERC20(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c); // wbnb
    
    function execute(IApePair[] memory _pairs, uint256[] memory _outAmounts, bool[] memory _directions, uint256 _amount) public onlyOwner isProfit returns(uint256) {
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

    function estimation() public view {

    }

    modifier isProfit {
        uint256 balance = baseToken.balanceOf(address(this));
        _;
        uint256 balanceAfter = baseToken.balanceOf(address(this));
        require(balanceAfter >= balance, "No profit");
    }
    
}