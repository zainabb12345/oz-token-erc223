pragma solidity >=0.5.0 <0.7.0;


/**
 * @title Contract that will work with ERC223 tokens.
 */

interface IERC223Recipient {
    /**
     * @dev Standard ERC223 function that will handle incoming token transfers.
     *
     * @param _from  Token sender address.
     * @param _value Amount of tokens.
     * @param _data  Transaction metadata.
     */
    function tokenFallback(address _from, uint256 _value, bytes calldata _data)
        external;
}