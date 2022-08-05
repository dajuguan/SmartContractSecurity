# 攻击名称
整数溢出(上溢和下溢)
# 攻击分类[CWE-682 ](https://swcregistry.io/docs/SWC-101#integer_overflow_mul_fixedsol)
计算不正确
# 攻击描述
当算数运算达到改类型的最大或最小值时，就是出现溢出。比如`uint8`类型，它的取值范围为0-2^8-1,当运算时尝试创建一个超出该类型可描述范围的值时，就会出现整数溢出。
# 合约案例
[完整代码和文档](https://github.com/dajuguan/SmartContractSecurity/tree/main/entries/SW101-IntegerOverflowAndUnderflow).
## 减法下溢、加法上溢和乘法下溢

```
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.6.10;
contract Overflow {
    uint8 public count = 1;

    function set(uint8 _count) public {
        count = _count;
    }

    function sub(uint8 input) public {
        count -= input;
    }

    function mul(uint8 input) public {
        count = 255；
        count *= input;
    }

    function add(uint8 input) public {
        count = 255;
        count += input;
    }

}
```

分别运行`sub`,`mul`和`add`函数，会发现与预期结果不一致。

## 防止策略
### 检查预期结果是否一致。
```
contract FixOverflow {
    uint8 public count = 1;
    function set(uint8 _count) public {
        count = _count;
    }

    function sub(uint8 input) public {
        count = sub(count, input);
    }

    function mul(uint8 input) public {
        count =  mul(count,input);
    }

    function add(uint8 input) public {
        count = 255;
        count = add(count, input);
    }

    function sub(uint8 a, uint8 b) internal pure returns (uint8) {
        require(b <= a, "Underflow!");
        return a -b;
    }

    function add(uint8 a, uint8 b) internal pure returns (uint8) {
        uint8 c = a + b;
        require( c>=a, "Overflow!");
        return c;
    }

    function mul(uint8 a, uint8 b) internal pure returns (uint8) {
        if (a == 0) {
            return 0;
        }
        uint8 c = a *b;
        require( c / a == b, "Overflow!");
        return c;
    }
}
```

### 或直接使用[openzeppelin数学库](https://docs.openzeppelin.com/contracts/4.x/utilities#api:math.adoc#SafeMath)。
```
pragma solidity ^0.8.0;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol"; //[Remix环境]

contract FixedOverflow {
    uint256 public count = 1;
    function set(uint256 _count) public {
        count = _count;
    }

    function sub(uint256 input) public {
        count = SafeMath.sub(count, input, "Overflow!");
    }

    function mul(uint256 input) public {
        count = 2**256 -1;
        count =  SafeMath.mul(count,input);
    }

    function add(uint256 input) public {
        count = 2**256 -1;
        count = SafeMath.add(count, input);
    }
}

```