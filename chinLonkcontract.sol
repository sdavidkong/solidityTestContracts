// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.7;


interface ERC20Interface {
    function totalSupply() external view returns(uint);
    function balanceOf(address tokenOwner) external view returns(uint balance);
    function transfer(address to, uint tokens) external returns(bool success);

    function allowance(address tokenOwner, address spender) external view returns(uint remaining);
    function approve(address spender, uint tokens) external returns(bool success);
    function transferFrom(address from, address to, uint tokens) external returns(bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract Chinlonks is ERC20Interface{
    string public name = "ChinLonk";
    string public symbol = "LONK";
    uint public decimals = 18;
    uint public override totalSupply;

    address public founder;
    mapping(address => uint) public balances;

    mapping(address => mapping(address => uint)) allowed;

    constructor(){
        totalSupply = 7777742000000000000000000;
        founder = msg.sender;
        balances[founder] = 42069000000000000000000;
    }

    function balanceOf(address tokenOwner) public view override returns(uint balance){
        return balances[tokenOwner];
    }

    function transfer(address to, uint tokens) public virtual override returns(bool success){
        require(balances[msg.sender] >= tokens);
        balances[to] += tokens;
        balances[msg.sender] -= tokens;
        emit Transfer(msg.sender, to, tokens);

        return true;
    }

    function allowance(address tokenOwner, address spender)  public view override returns(uint){
        return allowed[tokenOwner][spender];
    }

    function approve(address spender, uint tokens) public override returns(bool success){
        require(balances[msg.sender] >= tokens);
        require(tokens > 0);

        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
}
    function transferFrom(address from, address to, uint tokens) public virtual override returns(bool success){
        require(allowed[from][to] >= tokens);
        require(balances[from] >= tokens);

        balances[from] -= tokens;
        balances[to] += tokens;
        allowed[from][to] -= tokens;

        return true;
    }
}


contract ChinLonkICO is Chinlonks{
    address public admin;
    address payable public deposit;
    uint tokenPrice = 0.0023809523809524 ether; // 1eth = 420 LONK
    uint public hardCap = 300 ether;
    uint public raisedAmount;
    uint public saleStart = block.timestamp;
    uint public saleEnd = block.timestamp + 604800; // ico ends in one week
    uint public tokenTradeStart = saleEnd + 604800;
    uint public maxInvestment = 5 ether;
    uint public minInvestment = .01 ether;
    enum State {
        beforeStart,
        running,
        afterend,
        halted
    }
    State public icoState;

    constructor(address payable _deposit){
        deposit = _deposit;
        admin = msg.sender;
        icoState = State.beforeStart;
    }

    modifier onlyAdmin(){
        require(msg.sender == admin);
        _;
    }

    function halt() public onlyAdmin{
        icoState = State.halted;
    }

    function resume() public onlyAdmin{
        icoState = State.running;
    }

    function changeDepositAddress(address payable newDeposit) public onlyAdmin{
        deposit = newDeposit;
    }

    function getCurrentState() public view returns(State){
        if(icoState == State.halted){
            return State.halted;
        }else if(block.timestamp < saleStart){
            return State.beforeStart;
        }else if(block.timestamp >= saleStart && block.timestamp <= saleEnd){
            return State.running;
        }else{
            return State.afterend;
        }
    }

    event Invest(address investor, uint value, uint tokeks);

    function invest() payable public returns(bool){
        icoState = getCurrentState();
        require(icoState == State.running);
        require(msg.value >= minInvestment && msg.value <= maxInvestment);
        raisedAmount += msg.value;
        require(raisedAmount <= hardCap);

        uint tokens = msg.value / tokenPrice;

        balances[msg.sender] += tokens;
        balances[founder] -= tokens;
        deposit.transfer(msg.value);
        emit Invest(msg.sender, msg.value, tokens);

        return true;
    }

    receive() payable external{
        invest();
    }

     function transfer(address to, uint tokens) public override returns(bool success){
         require(block.timestamp > tokenTradeStart);
         Chinlonks.transfer(to, tokens);

         return true;
     }

     function transferFrom(address from, address to, uint tokens) public override returns(bool success){
          require(block.timestamp > tokenTradeStart);
          Chinlonks.transferFrom(from, to, tokens);

          return true;
     }       

     function notSoldTokenBurn() public returns(bool){
         icoState = getCurrentState();
         require(icoState == State.afterend);
         balances[founder] = 0;
         return true;
     }
}
