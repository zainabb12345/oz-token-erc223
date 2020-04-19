pragma solidity >=0.5.0 <0.7.0;
import "./IERCRecepient.sol";


contract ERC223ReceivingContract {
    function tokenFallback(address _from, uint256 _value, bytes memory _data)
        public
    {
        revert();
    }
}
