pragma solidity >= 0.8.9;

import "./interfaces/IUniswapV2Router02.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ArbitrageAnalyzer is Ownable {
    
    IUniswapV2Router02[] public routers;
    IERC20[] public tokens;


    function getBestRouter(IERC20 _token, IERC20 _base, uint256 _amount) public view returns(uint, address) {
        uint256 currentBestPrice = 0;
        address bestRouter;
        // is pair exist check from factory needed.
        for(uint i = 0; i < routers.length; i++) {
            IUniswapV2Router02 router = routers[i];
            address[] memory path = new address[](2);
            path[0] = address(_base);
            path[1] = address(_token);
            uint[] memory amounts = router.getAmountsOut(_amount, path);
            if(amounts[1] > currentBestPrice) {
                currentBestPrice = amounts[1];
                bestRouter = address(routers[i]);
            }
        }
        return (currentBestPrice, bestRouter);
    }

    function addRouter(address _router) public onlyOwner {
        routers.push(IUniswapV2Router02(_router));
    }

    function withdraw(address _token, uint256 _amount) public onlyOwner {
        IERC20 token = IERC20(_token);

        token.transfer(msg.sender, _amount);
    }
}