//SPDX-License-Identifier: Unlicensed

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

interface IBEP20 {
	function totalSupply() external view returns (uint256);

	function balanceOf(address account) external view returns (uint256);

	function transfer(address recipient, uint256 amount) external returns (bool);

	function allowance(address owner, address spender) external view returns (uint256);

	function approve(address spender, uint256 amount) external returns (bool);

	function transferFrom(
		address sender,
		address recipient,
		uint256 amount
	) external returns (bool);

	event Transfer(address indexed from, address indexed to, uint256 value);
	event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
	function add(uint256 a, uint256 b) internal pure returns (uint256) {
		uint256 c = a + b;
		require(c >= a, "SafeMath: addition overflow");

		return c;
	}

	function sub(uint256 a, uint256 b) internal pure returns (uint256) {
		return sub(a, b, "SafeMath: subtraction overflow");
	}

	function sub(
		uint256 a,
		uint256 b,
		string memory errorMessage
	) internal pure returns (uint256) {
		require(b <= a, errorMessage);
		uint256 c = a - b;

		return c;
	}

	function mul(uint256 a, uint256 b) internal pure returns (uint256) {
		if (a == 0) {
			return 0;
		}

		uint256 c = a * b;
		require(c / a == b, "SafeMath: multiplication overflow");

		return c;
	}

	function div(uint256 a, uint256 b) internal pure returns (uint256) {
		return div(a, b, "SafeMath: division by zero");
	}

	function div(
		uint256 a,
		uint256 b,
		string memory errorMessage
	) internal pure returns (uint256) {
		require(b > 0, errorMessage);
		uint256 c = a / b;
		return c;
	}

	function mod(uint256 a, uint256 b) internal pure returns (uint256) {
		return mod(a, b, "SafeMath: modulo by zero");
	}

	function mod(
		uint256 a,
		uint256 b,
		string memory errorMessage
	) internal pure returns (uint256) {
		require(b != 0, errorMessage);
		return a % b;
	}
}

abstract contract Context {
	function _msgSender() internal view virtual returns (address payable) {
		return msg.sender;
	}

	function _msgData() internal view virtual returns (bytes memory) {
		this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
		return msg.data;
	}
}

library Address {
	function isContract(address account) internal view returns (bool) {
		bytes32 codehash;
		bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
		// solhint-disable-next-line no-inline-assembly
		assembly {
			codehash := extcodehash(account)
		}
		return (codehash != accountHash && codehash != 0x0);
	}

	function sendValue(address payable recipient, uint256 amount) internal {
		require(address(this).balance >= amount, "Address: insufficient balance");
		(bool success, ) = recipient.call{ value: amount }("");
		require(success, "Address: unable to send value, recipient may have reverted");
	}

	function functionCall(address target, bytes memory data) internal returns (bytes memory) {
		return functionCall(target, data, "Address: low-level call failed");
	}

	function functionCall(
		address target,
		bytes memory data,
		string memory errorMessage
	) internal returns (bytes memory) {
		return _functionCallWithValue(target, data, 0, errorMessage);
	}

	function functionCallWithValue(
		address target,
		bytes memory data,
		uint256 value
	) internal returns (bytes memory) {
		return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
	}

	function functionCallWithValue(
		address target,
		bytes memory data,
		uint256 value,
		string memory errorMessage
	) internal returns (bytes memory) {
		require(address(this).balance >= value, "Address: insufficient balance for call");
		return _functionCallWithValue(target, data, value, errorMessage);
	}

	function _functionCallWithValue(
		address target,
		bytes memory data,
		uint256 weiValue,
		string memory errorMessage
	) private returns (bytes memory) {
		require(isContract(target), "Address: call to non-contract");

		// solhint-disable-next-line avoid-low-level-calls
		(bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
		if (success) {
			return returndata;
		} else {
			// Look for revert reason and bubble it up if present
			if (returndata.length > 0) {
				// The easiest way to bubble the revert reason is using memory via assembly

				// solhint-disable-next-line no-inline-assembly
				assembly {
					let returndata_size := mload(returndata)
					revert(add(32, returndata), returndata_size)
				}
			} else {
				revert(errorMessage);
			}
		}
	}
}

contract Ownable is Context {
	address private _owner;
	address private _previousOwner;
	uint256 private _lockTime;

	event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

	constructor() internal {
		address msgSender = _msgSender();
		_owner = msgSender;
		emit OwnershipTransferred(address(0), msgSender);
	}

	function owner() public view returns (address) {
		return _owner;
	}

	modifier onlyOwner() {
		require(_owner == _msgSender(), "Ownable: caller is not the owner");
		_;
	}

	function renounceOwnership() public virtual onlyOwner {
		emit OwnershipTransferred(_owner, address(0));
		_owner = address(0);
	}

	function transferOwnership(address newOwner) public virtual onlyOwner {
		require(newOwner != address(0), "Ownable: new owner is the zero address");
		emit OwnershipTransferred(_owner, newOwner);
		_owner = newOwner;
	}

	function geUnlockTime() public view returns (uint256) {
		return _lockTime;
	}

	//Locks the contract for owner for the amount of time provided
	function lock(uint256 time) public virtual onlyOwner {
		_previousOwner = _owner;
		_owner = address(0);
		_lockTime = now + time;
		emit OwnershipTransferred(_owner, address(0));
	}

	//Unlocks the contract for owner when _lockTime is exceeds
	function unlock() public virtual {
		require(_previousOwner == msg.sender, "You don't have permission to unlock");
		require(now > _lockTime, "Contract is locked until 7 days");
		emit OwnershipTransferred(_owner, _previousOwner);
		_owner = _previousOwner;
	}
}

interface IquickswapFactory {
	event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

	function feeTo() external view returns (address);

	function feeToSetter() external view returns (address);

	function getPair(address tokenA, address tokenB) external view returns (address pair);

	function allPairs(uint256) external view returns (address pair);

	function allPairsLength() external view returns (uint256);

	function createPair(address tokenA, address tokenB) external returns (address pair);

	function setFeeTo(address) external;

	function setFeeToSetter(address) external;
}

interface IquickswapPair {
	event Approval(address indexed owner, address indexed spender, uint256 value);
	event Transfer(address indexed from, address indexed to, uint256 value);

	function name() external pure returns (string memory);

	function symbol() external pure returns (string memory);

	function decimals() external pure returns (uint8);

	function totalSupply() external view returns (uint256);

	function balanceOf(address owner) external view returns (uint256);

	function allowance(address owner, address spender) external view returns (uint256);

	function approve(address spender, uint256 value) external returns (bool);

	function transfer(address to, uint256 value) external returns (bool);

	function transferFrom(
		address from,
		address to,
		uint256 value
	) external returns (bool);

	function DOMAIN_SEPARATOR() external view returns (bytes32);

	function PERMIT_TYPEHASH() external pure returns (bytes32);

	function nonces(address owner) external view returns (uint256);

	function permit(
		address owner,
		address spender,
		uint256 value,
		uint256 deadline,
		uint8 v,
		bytes32 r,
		bytes32 s
	) external;

	event Mint(address indexed sender, uint256 amount0, uint256 amount1);
	event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
	event Swap(
		address indexed sender,
		uint256 amount0In,
		uint256 amount1In,
		uint256 amount0Out,
		uint256 amount1Out,
		address indexed to
	);
	event Sync(uint112 reserve0, uint112 reserve1);

	function MINIMUM_LIQUIDITY() external pure returns (uint256);

	function factory() external view returns (address);

	function token0() external view returns (address);

	function token1() external view returns (address);

	function getReserves()
		external
		view
		returns (
			uint112 reserve0,
			uint112 reserve1,
			uint32 blockTimestampLast
		);

	function price0CumulativeLast() external view returns (uint256);

	function price1CumulativeLast() external view returns (uint256);

	function kLast() external view returns (uint256);

	function mint(address to) external returns (uint256 liquidity);

	function burn(address to) external returns (uint256 amount0, uint256 amount1);

	function swap(
		uint256 amount0Out,
		uint256 amount1Out,
		address to,
		bytes calldata data
	) external;

	function skim(address to) external;

	function sync() external;

	function initialize(address, address) external;
}

interface IquickswapRouter01 {
	function factory() external pure returns (address);

	function WETH() external pure returns (address);

	function addLiquidity(
		address tokenA,
		address tokenB,
		uint256 amountADesired,
		uint256 amountBDesired,
		uint256 amountAMin,
		uint256 amountBMin,
		address to,
		uint256 deadline
	)
		external
		returns (
			uint256 amountA,
			uint256 amountB,
			uint256 liquidity
		);

	function addLiquidityETH(
		address token,
		uint256 amountTokenDesired,
		uint256 amountTokenMin,
		uint256 amountETHMin,
		address to,
		uint256 deadline
	)
		external
		payable
		returns (
			uint256 amountToken,
			uint256 amountETH,
			uint256 liquidity
		);

	function removeLiquidity(
		address tokenA,
		address tokenB,
		uint256 liquidity,
		uint256 amountAMin,
		uint256 amountBMin,
		address to,
		uint256 deadline
	) external returns (uint256 amountA, uint256 amountB);

	function removeLiquidityETH(
		address token,
		uint256 liquidity,
		uint256 amountTokenMin,
		uint256 amountETHMin,
		address to,
		uint256 deadline
	) external returns (uint256 amountToken, uint256 amountETH);

	function removeLiquidityWithPermit(
		address tokenA,
		address tokenB,
		uint256 liquidity,
		uint256 amountAMin,
		uint256 amountBMin,
		address to,
		uint256 deadline,
		bool approveMax,
		uint8 v,
		bytes32 r,
		bytes32 s
	) external returns (uint256 amountA, uint256 amountB);

	function removeLiquidityETHWithPermit(
		address token,
		uint256 liquidity,
		uint256 amountTokenMin,
		uint256 amountETHMin,
		address to,
		uint256 deadline,
		bool approveMax,
		uint8 v,
		bytes32 r,
		bytes32 s
	) external returns (uint256 amountToken, uint256 amountETH);

	function swapExactTokensForTokens(
		uint256 amountIn,
		uint256 amountOutMin,
		address[] calldata path,
		address to,
		uint256 deadline
	) external returns (uint256[] memory amounts);

	function swapTokensForExactTokens(
		uint256 amountOut,
		uint256 amountInMax,
		address[] calldata path,
		address to,
		uint256 deadline
	) external returns (uint256[] memory amounts);

	function swapExactETHForTokens(
		uint256 amountOutMin,
		address[] calldata path,
		address to,
		uint256 deadline
	) external payable returns (uint256[] memory amounts);

	function swapTokensForExactETH(
		uint256 amountOut,
		uint256 amountInMax,
		address[] calldata path,
		address to,
		uint256 deadline
	) external returns (uint256[] memory amounts);

	function swapExactTokensForETH(
		uint256 amountIn,
		uint256 amountOutMin,
		address[] calldata path,
		address to,
		uint256 deadline
	) external returns (uint256[] memory amounts);

	function swapETHForExactTokens(
		uint256 amountOut,
		address[] calldata path,
		address to,
		uint256 deadline
	) external payable returns (uint256[] memory amounts);

	function quote(
		uint256 amountA,
		uint256 reserveA,
		uint256 reserveB
	) external pure returns (uint256 amountB);

	function getAmountOut(
		uint256 amountIn,
		uint256 reserveIn,
		uint256 reserveOut
	) external pure returns (uint256 amountOut);

	function getAmountIn(
		uint256 amountOut,
		uint256 reserveIn,
		uint256 reserveOut
	) external pure returns (uint256 amountIn);

	function getAmountsOut(uint256 amountIn, address[] calldata path)
		external
		view
		returns (uint256[] memory amounts);

	function getAmountsIn(uint256 amountOut, address[] calldata path)
		external
		view
		returns (uint256[] memory amounts);
}

interface IquickswapRouter02 is IquickswapRouter01 {
	function removeLiquidityETHSupportingFeeOnTransferTokens(
		address token,
		uint256 liquidity,
		uint256 amountTokenMin,
		uint256 amountETHMin,
		address to,
		uint256 deadline
	) external returns (uint256 amountETH);

	function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
		address token,
		uint256 liquidity,
		uint256 amountTokenMin,
		uint256 amountETHMin,
		address to,
		uint256 deadline,
		bool approveMax,
		uint8 v,
		bytes32 r,
		bytes32 s
	) external returns (uint256 amountETH);

	function swapExactTokensForTokensSupportingFeeOnTransferTokens(
		uint256 amountIn,
		uint256 amountOutMin,
		address[] calldata path,
		address to,
		uint256 deadline
	) external;

	function swapExactETHForTokensSupportingFeeOnTransferTokens(
		uint256 amountOutMin,
		address[] calldata path,
		address to,
		uint256 deadline
	) external payable;

	function swapExactTokensForETHSupportingFeeOnTransferTokens(
		uint256 amountIn,
		uint256 amountOutMin,
		address[] calldata path,
		address to,
		uint256 deadline
	) external;
}

abstract contract ReentrancyGuard {
	uint256 private constant _NOT_ENTERED = 1;
	uint256 private constant _ENTERED = 2;
	uint256 private _status;

	constructor() public {
		_status = _NOT_ENTERED;
	}

	modifier nonReentrant() {
		// On the first call to nonReentrant, _notEntered will be true
		require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

		// Any calls to nonReentrant after this point will fail
		_status = _ENTERED;

		_;

		// By storing the original value once again, a refund is triggered (see
		// https://eips.ethereum.org/EIPS/eip-2200)
		_status = _NOT_ENTERED;
	}

	modifier isHuman() {
		require(tx.origin == msg.sender, "sorry humans only");
		_;
	}
}

contract Rave is Context, IBEP20, Ownable, ReentrancyGuard {
	using SafeMath for uint256;
	using Address for address;

	mapping(address => uint256) private _rOwned;
	mapping(address => uint256) private _tOwned;
	mapping(address => mapping(address => uint256)) private _allowances;

	mapping(address => bool) private _isExcludedFromFee;
	mapping(address => bool) private _isExcluded;
	mapping(address => bool) private _isExcludedFromMaxTx;

	address[] private _excluded;

	uint256 private constant MAX = ~uint256(0);
	uint256 private _tTotal = 1000000000 * 10**6 * 10**18;
	uint256 private _rTotal = (MAX - (MAX % _tTotal));
	uint256 private _tFeeTotal;

	string private _name = "RAVE11";
	string private _symbol = "$RXI";
	uint8 private _decimals = 18;

	IquickswapRouter02 public immutable quickswapRouter;
	address public immutable quickswapPair;

	bool inSwapAndLiquify = false;

	event SwapAndLiquifyEnabledUpdated(bool enabled);
	event SwapAndLiquify(uint256 tokensSwapped, uint256 ethReceived, uint256 tokensIntoLiqudity);

	event ClaimETHSuccessfully(
		address recipient,
		uint256 ethReceived,
		uint256 nextAvailableClaimDate
	);

	modifier lockTheSwap {
		inSwapAndLiquify = true;
		_;
		inSwapAndLiquify = false;
	}

	constructor(address payable routerAddress) public {
		_rOwned[_msgSender()] = _rTotal;

		IquickswapRouter02 _quickswapRouter = IquickswapRouter02(routerAddress);
		// Create a quickswap pair for this new token
		quickswapPair = IquickswapFactory(_quickswapRouter.factory()).createPair(
			address(this),
			_quickswapRouter.WETH()
		);

		// set the rest of the contract variables
		quickswapRouter = _quickswapRouter;
	}

	//to be called after the constructor
	function preActivateContract() public onlyOwner {
		//exclude owner and this contract from fee
		_isExcludedFromFee[owner()] = true;
		_isExcludedFromFee[address(this)] = true;

		// exclude from max tx
		_isExcludedFromMaxTx[owner()] = true;
		_isExcludedFromMaxTx[address(this)] = true;
		_isExcludedFromMaxTx[address(0x000000000000000000000000000000000000dEaD)] = true;
		_isExcludedFromMaxTx[address(0)] = true;

		emit Transfer(address(0), _msgSender(), _tTotal);
	}

	function name() public view returns (string memory) {
		return _name;
	}

	function symbol() public view returns (string memory) {
		return _symbol;
	}

	function decimals() public view returns (uint8) {
		return _decimals;
	}

	function totalSupply() public view override returns (uint256) {
		return _tTotal;
	}

	function balanceOf(address account) public view override returns (uint256) {
		if (_isExcluded[account]) return _tOwned[account];
		return tokenFromReflection(_rOwned[account]);
	}

	function transfer(address recipient, uint256 amount) public override returns (bool) {
		_transfer(_msgSender(), recipient, amount, 0);
		return true;
	}

	function allowance(address owner, address spender) public view override returns (uint256) {
		return _allowances[owner][spender];
	}

	function approve(address spender, uint256 amount) public override returns (bool) {
		_approve(_msgSender(), spender, amount);
		return true;
	}

	function transferFrom(
		address sender,
		address recipient,
		uint256 amount
	) public override returns (bool) {
		_transfer(sender, recipient, amount, 0);
		_approve(
			sender,
			_msgSender(),
			_allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance")
		);
		return true;
	}

	function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
		_approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
		return true;
	}

	function decreaseAllowance(address spender, uint256 subtractedValue)
		public
		virtual
		returns (bool)
	{
		_approve(
			_msgSender(),
			spender,
			_allowances[_msgSender()][spender].sub(
				subtractedValue,
				"BEP20: decreased allowance below zero"
			)
		);
		return true;
	}

	function isExcludedFromReward(address account) public view returns (bool) {
		return _isExcluded[account];
	}

	function totalFees() public view returns (uint256) {
		return _tFeeTotal;
	}

	function deliver(uint256 tAmount) public {
		address sender = _msgSender();
		require(!_isExcluded[sender], "Excluded addresses cannot call this function");
		(uint256 rAmount, , , , , ) = _getValues(tAmount);
		_rOwned[sender] = _rOwned[sender].sub(rAmount);
		_rTotal = _rTotal.sub(rAmount);
		_tFeeTotal = _tFeeTotal.add(tAmount);
	}

	function reflectionFromToken(uint256 tAmount, bool deductTransferFee)
		public
		view
		returns (uint256)
	{
		require(tAmount <= _tTotal, "Amount must be less than supply");
		if (!deductTransferFee) {
			(uint256 rAmount, , , , , ) = _getValues(tAmount);
			return rAmount;
		} else {
			(, uint256 rTransferAmount, , , , ) = _getValues(tAmount);
			return rTransferAmount;
		}
	}

	function tokenFromReflection(uint256 rAmount) public view returns (uint256) {
		require(rAmount <= _rTotal, "Amount must be less than total reflections");
		uint256 currentRate = _getRate();
		return rAmount.div(currentRate);
	}

	function excludeFromReward(address account) public onlyOwner() {
		// require(account != 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D, 'We can not exclude quickswap router.');
		require(!_isExcluded[account], "Account is already excluded");
		if (_rOwned[account] > 0) {
			_tOwned[account] = tokenFromReflection(_rOwned[account]);
		}
		_isExcluded[account] = true;
		_excluded.push(account);
	}

	function includeInReward(address account) external onlyOwner() {
		require(_isExcluded[account], "Account is already excluded");
		for (uint256 i = 0; i < _excluded.length; i++) {
			if (_excluded[i] == account) {
				_excluded[i] = _excluded[_excluded.length - 1];
				_tOwned[account] = 0;
				_isExcluded[account] = false;
				_excluded.pop();
				break;
			}
		}
	}

	function _transferBothExcluded(
		address sender,
		address recipient,
		uint256 tAmount
	) private {
		(
			uint256 rAmount,
			uint256 rTransferAmount,
			uint256 rFee,
			uint256 tTransferAmount,
			uint256 tFee,
			uint256 tLiquidity
		) = _getValues(tAmount);
		_tOwned[sender] = _tOwned[sender].sub(tAmount);
		_rOwned[sender] = _rOwned[sender].sub(rAmount);
		_tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
		_rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
		_takeLiquidity(tLiquidity);
		_reflectFee(rFee, tFee);
		emit Transfer(sender, recipient, tTransferAmount);
	}

	function excludeFromFee(address account) public onlyOwner {
		_isExcludedFromFee[account] = true;
	}

	function includeInFee(address account) public onlyOwner {
		_isExcludedFromFee[account] = false;
	}

	function setTaxFeePercent(uint256 taxFee) external onlyOwner() {
		_taxFee = taxFee;
	}

	function setLiquidityFeePercent(uint256 liquidityFee) external onlyOwner() {
		_liquidityFee = liquidityFee;
	}

	function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
		swapAndLiquifyEnabled = _enabled;
		emit SwapAndLiquifyEnabledUpdated(_enabled);
	}

	//to receive ETH from quickswapRouter when swapping
	receive() external payable {}

	function _reflectFee(uint256 rFee, uint256 tFee) private {
		_rTotal = _rTotal.sub(rFee);
		_tFeeTotal = _tFeeTotal.add(tFee);
	}

	function _getValues(uint256 tAmount)
		private
		view
		returns (
			uint256,
			uint256,
			uint256,
			uint256,
			uint256,
			uint256
		)
	{
		(uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getTValues(tAmount);
		(uint256 rAmount, uint256 rTransferAmount, uint256 rFee) =
			_getRValues(tAmount, tFee, tLiquidity, _getRate());
		return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tLiquidity);
	}

	function _getTValues(uint256 tAmount)
		private
		view
		returns (
			uint256,
			uint256,
			uint256
		)
	{
		uint256 tFee = calculateTaxFee(tAmount);
		uint256 tLiquidity = calculateLiquidityFee(tAmount);
		uint256 tTransferAmount = tAmount.sub(tFee).sub(tLiquidity);
		return (tTransferAmount, tFee, tLiquidity);
	}

	function _getRValues(
		uint256 tAmount,
		uint256 tFee,
		uint256 tLiquidity,
		uint256 currentRate
	)
		private
		pure
		returns (
			uint256,
			uint256,
			uint256
		)
	{
		uint256 rAmount = tAmount.mul(currentRate);
		uint256 rFee = tFee.mul(currentRate);
		uint256 rLiquidity = tLiquidity.mul(currentRate);
		uint256 rTransferAmount = rAmount.sub(rFee).sub(rLiquidity);
		return (rAmount, rTransferAmount, rFee);
	}

	function _getRate() private view returns (uint256) {
		(uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
		return rSupply.div(tSupply);
	}

	function _getCurrentSupply() private view returns (uint256, uint256) {
		uint256 rSupply = _rTotal;
		uint256 tSupply = _tTotal;
		for (uint256 i = 0; i < _excluded.length; i++) {
			if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply)
				return (_rTotal, _tTotal);
			rSupply = rSupply.sub(_rOwned[_excluded[i]]);
			tSupply = tSupply.sub(_tOwned[_excluded[i]]);
		}
		if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
		return (rSupply, tSupply);
	}

	function _takeLiquidity(uint256 tLiquidity) private {
		uint256 currentRate = _getRate();
		uint256 rLiquidity = tLiquidity.mul(currentRate);
		_rOwned[address(this)] = _rOwned[address(this)].add(rLiquidity);
		if (_isExcluded[address(this)]) _tOwned[address(this)] = _tOwned[address(this)].add(tLiquidity);
	}

	function calculateTaxFee(uint256 _amount) private view returns (uint256) {
		return _amount.mul(_taxFee).div(10**2);
	}

	function calculateLiquidityFee(uint256 _amount) private view returns (uint256) {
		return _amount.mul(_liquidityFee).div(10**2);
	}

	function removeAllFee() private {
		if (_taxFee == 0 && _liquidityFee == 0) return;

		_previousTaxFee = _taxFee;
		_previousLiquidityFee = _liquidityFee;

		_taxFee = 0;
		_liquidityFee = 0;
	}

	function restoreAllFee() private {
		_taxFee = _previousTaxFee;
		_liquidityFee = _previousLiquidityFee;
	}

	function isExcludedFromFee(address account) public view returns (bool) {
		return _isExcludedFromFee[account];
	}

	function _approve(
		address owner,
		address spender,
		uint256 amount
	) private {
		require(owner != address(0), "ERC20: approve from the zero address");
		require(spender != address(0), "ERC20: approve to the zero address");

		_allowances[owner][spender] = amount;
		emit Approval(owner, spender, amount);
	}

	function _transfer(
		address from,
		address to,
		uint256 amount,
		uint256 value
	) private {
		require(from != address(0), "ERC20: transfer from the zero address");
		require(to != address(0), "ERC20: transfer to the zero address");
		require(amount > 0, "Transfer amount must be greater than zero");

		ensureMaxTxAmount(from, to, amount, value);

		// swap and liquify
		swapAndLiquify(from, to);

		//indicates if fee should be deducted from transfer
		bool takeFee = true;

		//if any account belongs to _isExcludedFromFee account then remove the fee
		if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
			takeFee = false;
		}

		//transfer amount, it will take tax, burn, liquidity fee
		_tokenTransfer(from, to, amount, takeFee);
	}

	//this method is responsible for taking all fee, if takeFee is true
	function _tokenTransfer(
		address sender,
		address recipient,
		uint256 amount,
		bool takeFee
	) private {
		if (!takeFee) removeAllFee();

		// top up claim cycle
		topUpClaimCycleAfterTransfer(recipient, amount);

		if (_isExcluded[sender] && !_isExcluded[recipient]) {
			_transferFromExcluded(sender, recipient, amount);
		} else if (!_isExcluded[sender] && _isExcluded[recipient]) {
			_transferToExcluded(sender, recipient, amount);
		} else if (!_isExcluded[sender] && !_isExcluded[recipient]) {
			_transferStandard(sender, recipient, amount);
		} else if (_isExcluded[sender] && _isExcluded[recipient]) {
			_transferBothExcluded(sender, recipient, amount);
		} else {
			_transferStandard(sender, recipient, amount);
		}

		if (!takeFee) restoreAllFee();
	}

	function _transferStandard(
		address sender,
		address recipient,
		uint256 tAmount
	) private {
		(
			uint256 rAmount,
			uint256 rTransferAmount,
			uint256 rFee,
			uint256 tTransferAmount,
			uint256 tFee,
			uint256 tLiquidity
		) = _getValues(tAmount);
		_rOwned[sender] = _rOwned[sender].sub(rAmount);
		_rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
		_takeLiquidity(tLiquidity);
		_reflectFee(rFee, tFee);
		emit Transfer(sender, recipient, tTransferAmount);
	}

	function _transferToExcluded(
		address sender,
		address recipient,
		uint256 tAmount
	) private {
		(
			uint256 rAmount,
			uint256 rTransferAmount,
			uint256 rFee,
			uint256 tTransferAmount,
			uint256 tFee,
			uint256 tLiquidity
		) = _getValues(tAmount);
		_rOwned[sender] = _rOwned[sender].sub(rAmount);
		_tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
		_rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
		_takeLiquidity(tLiquidity);
		_reflectFee(rFee, tFee);
		emit Transfer(sender, recipient, tTransferAmount);
	}

	function _transferFromExcluded(
		address sender,
		address recipient,
		uint256 tAmount
	) private {
		(
			uint256 rAmount,
			uint256 rTransferAmount,
			uint256 rFee,
			uint256 tTransferAmount,
			uint256 tFee,
			uint256 tLiquidity
		) = _getValues(tAmount);
		_tOwned[sender] = _tOwned[sender].sub(tAmount);
		_rOwned[sender] = _rOwned[sender].sub(rAmount);
		_rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
		_takeLiquidity(tLiquidity);
		_reflectFee(rFee, tFee);
		emit Transfer(sender, recipient, tTransferAmount);
	}

	// Innovation for protocol by RAVE Team
	uint256 public rewardCycleBlock = 7 days;
	uint256 public easyRewardCycleBlock = 1 days;
	uint256 public threshHoldTopUpRate = 2; // 2 percent
	uint256 public _maxTxAmount = _tTotal; // should be 1% percent per transaction, will be set again at activateContract() function
	uint256 public disruptiveCoverageFee = 2 ether; // antiwhale
	mapping(address => uint256) public nextAvailableClaimDate;
	bool public swapAndLiquifyEnabled = false; // should be true
	uint256 public disruptiveTransferEnabledFrom = 0;
	uint256 public disableEasyRewardFrom = 0;
	uint256 public winningDoubleRewardPercentage = 5;

	uint256 public _taxFee = 2;
	uint256 private _previousTaxFee = _taxFee;

	uint256 public not  = 8; // 4% will be added pool, 4% will be converted to ETH
	uint256 private _previousLiquidityFee = _liquidityFee;
	uint256 public rewardThreshold = 1 ether;

	uint256 minTokenNumberToSell = _tTotal.mul(1).div(100).div(10); // 1% max tx amount will trigger swap and add liquidity

	function setMaxTxPercent(uint256 maxTxPercent) public onlyOwner() {
		_maxTxAmount = _tTotal.mul(maxTxPercent).div(10000);
	}

	function setExcludeFromMaxTx(address _address, bool value) public onlyOwner {
		_isExcludedFromMaxTx[_address] = value;
	}

	function calculateETHReward(address ofAddress) public view returns (uint256) {
		uint256 totalSupply =
			uint256(_tTotal)
				.sub(balanceOf(address(0)))
				.sub(balanceOf(0x000000000000000000000000000000000000dEaD)) // exclude burned wallet
				.sub(balanceOf(address(quickswapPair)));
		// exclude liquidity wallet

		return
			calculateETHReward(
				_tTotal,
				balanceOf(address(ofAddress)),
				address(this).balance,
				winningDoubleRewardPercentage,
				totalSupply,
				ofAddress
			);
	}

	function getRewardCycleBlock() public view returns (uint256) {
		if (block.timestamp >= disableEasyRewardFrom) return rewardCycleBlock;
		return easyRewardCycleBlock;
	}

	function claimETHReward() public isHuman nonReentrant {
		require(
			nextAvailableClaimDate[msg.sender] <= block.timestamp,
			"Error: next available not reached"
		);
		require(balanceOf(msg.sender) >= 0, "Error: must own MRAT to claim reward");

		uint256 reward = calculateETHReward(msg.sender);

		// reward threshold
		if (reward >= rewardThreshold) {
			swapETHForTokens(
				address(quickswapRouter),
				address(0x000000000000000000000000000000000000dEaD),
				reward.div(5)
			);
			reward = reward.sub(reward.div(5));
		}

		// update rewardCycleBlock
		nextAvailableClaimDate[msg.sender] = block.timestamp + getRewardCycleBlock();
		emit ClaimETHSuccessfully(msg.sender, reward, nextAvailableClaimDate[msg.sender]);

		(bool sent, ) = address(msg.sender).call{ value: reward }("");
		require(sent, "Error: Cannot withdraw reward");
	}

	function topUpClaimCycleAfterTransfer(address recipient, uint256 amount) private {
		uint256 currentRecipientBalance = balanceOf(recipient);
		uint256 basedRewardCycleBlock = getRewardCycleBlock();

		nextAvailableClaimDate[recipient] =
			nextAvailableClaimDate[recipient] +
			calculateTopUpClaim(
				currentRecipientBalance,
				basedRewardCycleBlock,
				threshHoldTopUpRate,
				amount
			);
	}

	function ensureMaxTxAmount(
		address from,
		address to,
		uint256 amount,
		uint256 value
	) private {
		if (
			_isExcludedFromMaxTx[from] == false && // default will be false
			_isExcludedFromMaxTx[to] == false // default will be false
		) {
			if (value < disruptiveCoverageFee && block.timestamp >= disruptiveTransferEnabledFrom) {
				require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
			}
		}
	}

	function disruptiveTransfer(address recipient, uint256 amount) public payable returns (bool) {
		_transfer(_msgSender(), recipient, amount, msg.value);
		return true;
	}

	function swapAndLiquify(address from, address to) private {
		// is the token balance of this contract address over the min number of
		// tokens that we need to initiate a swap + liquidity lock?
		// also, don't get caught in a circular liquidity event.
		// also, don't swap & liquify if sender is quickswap pair.
		uint256 contractTokenBalance = balanceOf(address(this));

		if (contractTokenBalance >= _maxTxAmount) {
			contractTokenBalance = _maxTxAmount;
		}

		bool shouldSell = contractTokenBalance >= minTokenNumberToSell;

		if (
			!inSwapAndLiquify &&
			shouldSell &&
			from != quickswapPair &&
			swapAndLiquifyEnabled &&
			!(from == address(this) && to == address(quickswapPair)) // swap 1 time
		) {
			// only sell for minTokenNumberToSell, decouple from _maxTxAmount
			contractTokenBalance = minTokenNumberToSell;

			// add liquidity
			// split the contract balance into 3 pieces
			uint256 pooledETH = contractTokenBalance.div(2);
			uint256 piece = contractTokenBalance.sub(pooledETH).div(2);
			uint256 otherPiece = contractTokenBalance.sub(piece);

			uint256 tokenAmountToBeSwapped = pooledETH.add(piece);

			uint256 initialBalance = address(this).balance;

			// now is to lock into staking pool
			swapTokensForEth(address(quickswapRouter), tokenAmountToBeSwapped);

			// how much ETH did we just swap into?

			// capture the contract's current ETH balance.
			// this is so that we can capture exactly the amount of ETH that the
			// swap creates, and not make the liquidity event include any ETH that
			// has been manually sent to the contract
			uint256 deltaBalance = address(this).balance.sub(initialBalance);

			uint256 ETHToBeAddedToLiquidity = deltaBalance.div(3);

			// add liquidity to quickswap
			addLiquidity(address(quickswapRouter), owner(), otherPiece, ETHToBeAddedToLiquidity);

			emit SwapAndLiquify(piece, deltaBalance, otherPiece);
		}
	}

	function activateContract() public onlyOwner {
		// reward claim
		disableEasyRewardFrom = block.timestamp + 1 weeks;
		rewardCycleBlock = 7 days;
		easyRewardCycleBlock = 1 days;

		winningDoubleRewardPercentage = 5;

		// protocol
		disruptiveCoverageFee = 2 ether;
		disruptiveTransferEnabledFrom = block.timestamp;
		setMaxTxPercent(1);
		setSwapAndLiquifyEnabled(true);

		// approve contract
		_approve(address(this), address(quickswapRouter), 2**256 - 1);
	}

	function random(
		uint256 from,
		uint256 to,
		uint256 salty
	) private view returns (uint256) {
		uint256 seed =
			uint256(
				keccak256(
					abi.encodePacked(
						block.timestamp +
							block.difficulty +
							((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (now)) +
							block.gaslimit +
							((uint256(keccak256(abi.encodePacked(msg.sender)))) / (now)) +
							block.number +
							salty
					)
				)
			);
		return seed.mod(to - from) + from;
	}

	function isLotteryWon(uint256 salty, uint256 winningDoubleRewardPercentage)
		private
		view
		returns (bool)
	{
		uint256 luckyNumber = random(0, 100, salty);
		uint256 winPercentage = winningDoubleRewardPercentage;
		return luckyNumber <= winPercentage;
	}

	function calculateETHReward(
		uint256 _tTotal,
		uint256 currentBalance,
		uint256 currentETHPool,
		uint256 winningDoubleRewardPercentage,
		uint256 totalSupply,
		address ofAddress
	) public view returns (uint256) {
		uint256 ETHPool = currentETHPool;

		// calculate reward to send
		bool isLotteryWonOnClaim = isLotteryWon(currentBalance, winningDoubleRewardPercentage);
		uint256 multiplier = 100;

		if (isLotteryWonOnClaim) {
			multiplier = random(150, 200, currentBalance);
		}

		// now calculate reward
		uint256 reward = ETHPool.mul(multiplier).mul(currentBalance).div(100).div(totalSupply);

		return reward;
	}

	function calculateTopUpClaim(
		uint256 currentRecipientBalance,
		uint256 basedRewardCycleBlock,
		uint256 threshHoldTopUpRate,
		uint256 amount
	) public returns (uint256) {
		if (currentRecipientBalance == 0) {
			return block.timestamp + basedRewardCycleBlock;
		} else {
			uint256 rate = amount.mul(100).div(currentRecipientBalance);

			if (uint256(rate) >= threshHoldTopUpRate) {
				uint256 incurCycleBlock = basedRewardCycleBlock.mul(uint256(rate)).div(100);

				if (incurCycleBlock >= basedRewardCycleBlock) {
					incurCycleBlock = basedRewardCycleBlock;
				}

				return incurCycleBlock;
			}

			return 0;
		}
	}

	function swapTokensForEth(address routerAddress, uint256 tokenAmount) public {
		IquickswapRouter02 quickswapRouter = IquickswapRouter02(routerAddress);

		// generate the quickswap pair path of token -> weth
		address[] memory path = new address[](2);
		path[0] = address(this);
		path[1] = quickswapRouter.WETH();

		// make the swap
		quickswapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
			tokenAmount,
			0, // accept any amount of ETH
			path,
			address(this),
			block.timestamp
		);
	}

	function swapETHForTokens(
		address routerAddress,
		address recipient,
		uint256 ethAmount
	) public {
		IquickswapRouter02 quickswapRouter = IquickswapRouter02(routerAddress);

		// generate the quickswap pair path of token -> weth
		address[] memory path = new address[](2);
		path[0] = quickswapRouter.WETH();
		path[1] = address(this);

		// make the swap
		quickswapRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{ value: ethAmount }(
			0, // accept any amount of ETH
			path,
			address(recipient),
			block.timestamp + 360
		);
	}

	function addLiquidity(
		address routerAddress,
		address owner,
		uint256 tokenAmount,
		uint256 ethAmount
	) public {
		IquickswapRouter02 quickswapRouter = IquickswapRouter02(routerAddress);

		// add the liquidity
		quickswapRouter.addLiquidityETH{ value: ethAmount }(
			address(this),
			tokenAmount,
			0, // slippage is unavoidable
			0, // slippage is unavoidable
			owner,
			block.timestamp + 360
		);
	}
}
