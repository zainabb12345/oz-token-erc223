pragma solidity >=0.5.0 <0.7.0;
import "./Initializable.sol";
import "./IERC223.sol";
import "./ReceivingContract.sol";
import "../library/safeMath.sol";
import "../library/Address.sol";


// Ownable contract from open zepplin libraray

contract Ownable {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() public {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * > Note: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address _newOwner) public onlyOwner {
        _transferOwnership(_newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address _newOwner) internal {
        require(
            _newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, _newOwner);
        _owner = _newOwner;
    }
}


// IERC20\ interface

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address _tokenOwner) external view returns (uint256);

    function allowance(address _tokenOwner, address _spender)
        external
        view
        returns (uint256);

    function approve(address _spender, uint256 _tokens) external returns (bool);

    function transferFrom(address _from, address _to, uint256 _tokens)
        external
        returns (bool);

    event Approval(
        address indexed tokenOwner,
        address indexed spender,
        uint256 tokens
    );
    event Transfer(address indexed from, address indexed to, uint256 tokens);
}


// actual contract

contract oz223 is Ownable, IERC20, Initializable, IERC223 {
    using SafeMath for uint256;
    // using Address for uint256;
    //state variables
    string public name;
    string public symbol;
    uint256 public totalsupply;
    uint256 public decimal;
    //mappings
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowances;

    event Approval(
        address indexed tokenOwner,
        address indexed spender,
        uint256 tokens
    );
    event Transfer(address indexed from, address indexed to, uint256 tokens);

    //upgradeable constructor
    function initialize() public initializer {
        name = "ABC";
        symbol = "ABC";
        decimal = 6;
        totalsupply = 1000000 * 10**decimal;
        balances[msg.sender] = totalsupply;
    }

    //to check total supply
    function totalSupply() external override view returns (uint256) {
        return totalsupply;
    }

    //to check balance
    function balanceOf(address _tokenOwner) external override view returns (uint256) {
        return balances[_tokenOwner];
    }

    //erc223standard
    function transfer(address _to, uint256 _value)
        public override
        returns (bool success)
    {
        bytes memory empty = hex"00000000";
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        if (Address.isContract(_to)) {
            ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
            receiver.tokenFallback(msg.sender, _value, empty);
        }
        emit Transfer(msg.sender, _to, _value, empty);
        return true;
    }

    //erc223 backward compatibility
    function transfer(address _to, uint256 _value, bytes memory _data)
        public override
        returns (bool success)
    {
        // Standard function transfer similar to ERC20 transfer with no _data .
        // Added due to backwards compatibility reasons .
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        if (Address.isContract(_to)) {
            ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
            receiver.tokenFallback(msg.sender, _value, _data);
        }
        emit Transfer(msg.sender, _to, _value, _data);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value)
        public override
        returns (bool)
    {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowances[_from][msg.sender]);

        balances[_from] = SafeMath.sub(balances[_from], _value);
        balances[_to] = SafeMath.add(balances[_to], _value);
        allowances[_from][msg.sender] = SafeMath.sub(
            allowances[_from][msg.sender],
            _value
        );
        Transfer(_from, _to, _value);
        return true;
    }

    function allowance(address _tokenOwner, address _spender)
        external override
        view
        returns (uint256)
    {
        return allowances[_tokenOwner][_spender];
    }

    function approve(address _spender, uint256 _tokens)
        external override
        returns (bool)
    {
        _approve(msg.sender, _spender, _tokens);
        return true;
    }

    function _approve(address _owner, address _spender, uint256 _value)
        internal
    {
        require(_owner != address(0), "ERC20: approve from the zero address");
        require(_spender != address(0), "ERC20: approve to the zero address");

        allowances[_owner][_spender] = _value;
        emit Approval(_owner, _spender, _value);
    }

    function isContract(address _adrss) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;


            bytes32 accountHash
         = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            codehash := extcodehash(_adrss)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

    // don't accept eth
    // taken from ethplode token contract
    receive() external payable {
        revert();
    }
}
