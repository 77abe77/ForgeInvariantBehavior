// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;


import {Test, TestBase, StdCheats, console, Vm} from "forge-std/Test.sol";

library StringHelper {
    function add(string memory s1, string memory s2) internal pure returns (string memory) {
        return string.concat(s1, s2);
    }
}

library FFILog {
    function ffiLog(Vm vm, string memory s) internal {
        string[] memory cmds = new string[](4);
        cmds[0] = "python3";
        cmds[1] = "test/log.py";
        cmds[2] = "--append";
        cmds[3] = s;
        vm.ffi(cmds);
    }
}

contract TargetContract {
    uint public counter;
    uint public a;
    uint public b;

    function incrementA() public {
        a++;
        counter++;
    }

    function incrementB() public {
        b++;
        counter++;
    }
}

contract Handler is TestBase, StdCheats {
    using StringHelper for string;
    using FFILog for Vm;

    TargetContract public t;

    uint public counter;
    uint public a;
    uint public b;

    function incrementA() public {
        a += 1;
        counter++;
        t.incrementA();
        vm.ffiLog(string("incrementA()")
           .add(string("\n             :           handler:").add(vm.toString(address(this))))
           .add(string("\n             :   block.timestamp:").add(vm.toString(block.timestamp)))
           .add(string("\n             :      block.number:").add(vm.toString(block.number)))
           .add(string("\n             : handler.t.counter:").add(vm.toString(t.counter())))
           .add(string("\n             :       handler.t.a:").add(vm.toString(t.a())))
           .add(string("\n             :       handler.t.b:").add(vm.toString(t.b())))
           .add(string("\n             :         handler.a:").add(vm.toString(a)))
           .add(string("\n             :   handler.counter:").add(vm.toString(counter)))
           .add(string("\n             :         handler.a:").add(vm.toString(a)))
           .add(string("\n             :         handler.b:").add(vm.toString(b))));
    }

    function incrementB() public {
        b += 1;
        counter++;
        t.incrementB();
        vm.ffiLog(string("incrementB()")
           .add(string("\n             :           handler:").add(vm.toString(address(this))))
           .add(string("\n             :   block.timestamp:").add(vm.toString(block.timestamp)))
           .add(string("\n             :      block.number:").add(vm.toString(block.number)))
           .add(string("\n             : handler.t.counter:").add(vm.toString(t.counter())))
           .add(string("\n             :       handler.t.a:").add(vm.toString(t.a())))
           .add(string("\n             :       handler.t.b:").add(vm.toString(t.b())))
           .add(string("\n             :   handler.counter:").add(vm.toString(counter)))
           .add(string("\n             :         handler.a:").add(vm.toString(a)))
           .add(string("\n             :         handler.b:").add(vm.toString(b))));
    }

    constructor() {
        vm.ffiLog("Handler()");
        t = new TargetContract();
    }

    modifier useActor() {
        vm.ffiLog("[modifier] useActor");

        startHoax(msg.sender);
        _;
        vm.stopPrank();
    }

    function f1(uint seed) external {
        if (seed <= type(uint).max / 100 * 20) {
            vm.ffiLog("[handler] skip by 1 day");
            skip(1 days);
        }
        vm.ffiLog(string("f1( ").add(vm.toString(seed)).add(string(" )"))
           .add(string("\n             :           handler:").add(vm.toString(address(this))))
           .add(string("\n             :   block.timestamp:").add(vm.toString(block.timestamp)))
           .add(string("\n             :      block.number:").add(vm.toString(block.number)))
           .add(string("\n             : handler.t.counter:").add(vm.toString(t.counter())))
           .add(string("\n             :       handler.t.a:").add(vm.toString(t.a())))
           .add(string("\n             :       handler.t.b:").add(vm.toString(t.b())))
           .add(string("\n             :   handler.counter:").add(vm.toString(counter)))
           .add(string("\n             :         handler.a:").add(vm.toString(a)))
           .add(string("\n             :         handler.b:").add(vm.toString(b))));
    }

    function f2(uint seed) external useActor() {
        if (seed <= type(uint).max / 100 * 20) {
            vm.ffiLog("[handler] skip by 1 day");
            skip(1 days);
        }
        vm.ffiLog(string("f2( ").add(vm.toString(seed)).add(string(" )"))
           .add(string("\n             :           handler:").add(vm.toString(address(this))))
           .add(string("\n             :   block.timestamp:").add(vm.toString(block.timestamp)))
           .add(string("\n             :      block.number:").add(vm.toString(block.number)))
           .add(string("\n             : handler.t.counter:").add(vm.toString(t.counter())))
           .add(string("\n             :       handler.t.a:").add(vm.toString(t.a())))
           .add(string("\n             :       handler.t.b:").add(vm.toString(t.b())))
           .add(string("\n             :   handler.counter:").add(vm.toString(counter)))
           .add(string("\n             :         handler.a:").add(vm.toString(a)))
           .add(string("\n             :         handler.b:").add(vm.toString(b))));

    }
}

contract TestContract is Test {
    using StringHelper for string;
    using FFILog for Vm;
    Handler handler;

    uint counter;

    constructor() {
        string[] memory cmds = new string[](3);
        cmds[0] = "python3";
        cmds[1] = "test/log.py";
        cmds[2] = "--new";
        vm.ffi(cmds);
    }

    function setUp() public {
        vm.ffiLog("Test::setUp()");
        handler = new Handler();
        bytes4[] memory selectors = new bytes4[](4);
        selectors[0] = bytes4(keccak256("f1(uint256)"));
        selectors[1] = bytes4(keccak256("f2(uint256)"));
        selectors[2] = bytes4(keccak256("incrementA()"));
        selectors[3] = bytes4(keccak256("incrementB()"));
        targetSelector(FuzzSelector({
            addr: address(handler),
            selectors: selectors
        }));
        targetContract(address(this));
    }

    /// forge-config: default.invariant.runs = 1
    /// forge-config: default.invariant.depth = 10
    /// forge-config: default.invariant.fail-on-revert = true
    /// forge-config: default.invariant.call-override = false
    function invariant_A() external {
        vm.ffiLog(string("invariant_A():")
           .add(string("\n             :             handler:").add(vm.toString(address(handler))))
           .add(string("\n             :     block.timestamp:").add(vm.toString(block.timestamp)))
           .add(string("\n             :        block.number:").add(vm.toString(block.number)))
           .add(string("\n             :             counter:").add(vm.toString(counter)))
           .add(string("\n             : handler.t().counter:").add(vm.toString(handler.t().counter())))
           .add(string("\n             :       handler.t().a:").add(vm.toString(handler.t().a())))
           .add(string("\n             :       handler.t().b:").add(vm.toString(handler.t().b())))
           .add(string("\n             :     handler.counter:").add(vm.toString(handler.counter())))
           .add(string("\n             :           handler.a:").add(vm.toString(handler.a())))
           .add(string("\n             :           handler.b:").add(vm.toString(handler.b()))));
    }



}
