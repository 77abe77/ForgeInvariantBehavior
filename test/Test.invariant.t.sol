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

contract Handler is TestBase, StdCheats {
    using StringHelper for string;
    using FFILog for Vm;

    uint public counter;
    uint public a;
    uint public b;
    // LiquidityVault lVault;
    function incrementA() public {
       vm.ffiLog("incrementA");
        a += 1;
        counter++;
    }

    function incrementB() public {
       vm.ffiLog("incrementB");
        b += 1;
        counter++;
    }

    constructor() {
        vm.ffiLog("Handler()");
    }

    modifier useActor() {
        vm.ffiLog("[modifier] useActor");

        startHoax(msg.sender);
        _;
        vm.stopPrank();
    }

    function mintV2(uint seed) external {
        if (seed <= type(uint).max / 100 * 20) {
            vm.ffiLog("\n[handler] skip by 1 day\n");
            skip(1 days);
        }
        vm.ffiLog(string("mintV2( ").add(vm.toString(seed)).add(string(" )"))
           .add(string("\n             :       handler:").add(vm.toString(address(this))))
           .add(string("\n             :     timestamp:").add(vm.toString(block.timestamp)))
           .add(string("\n             : handler.nonce:").add(vm.toString(counter)))
           .add(string("\n             :     handler.a:").add(vm.toString(a)))
           .add(string("\n             :     handler.b:").add(vm.toString(b))));
    }

    function swapV2(uint seed) external useActor() {
        if (seed <= type(uint).max / 100 * 20) {
            vm.ffiLog("\n[handler] skip by 1 day\n");
            skip(1 days);
        }
        vm.ffiLog(string("swapV2( ").add(vm.toString(seed)).add(string(" )"))
           .add(string("\n             :       handler:").add(vm.toString(address(this))))
           .add(string("\n             :     timestamp:").add(vm.toString(block.timestamp)))
           .add(string("\n             : handler.nonce:").add(vm.toString(counter)))
           .add(string("\n             :     handler.a:").add(vm.toString(a)))
           .add(string("\n             :     handler.b:").add(vm.toString(b))));

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
        bytes4[] memory selectors = new bytes4[](2);
        selectors[0] = bytes4(keccak256("mintV2(uint256)"));
        selectors[1] = bytes4(keccak256("swapV2(uint256)"));
        targetSelector(FuzzSelector({
            addr: address(handler),
            selectors: selectors
        }));
        targetContract(address(this));
    }

    /// forge-config: default.invariant.runs = 3
    /// forge-config: default.invariant.depth = 10
    /// forge-config: default.invariant.fail-on-revert = true
    /// forge-config: default.invariant.call-override = false
    function invariant_A() external {
        vm.ffiLog(string("invariant_A(): [pre]:")
           .add(string("\n             :       handler:").add(vm.toString(address(handler))))
           .add(string("\n             :     timestamp:").add(vm.toString(block.timestamp)))
           .add(string("\n             :         nonce:").add(vm.toString(counter)))
           .add(string("\n             : handler.nonce:").add(vm.toString(handler.counter())))
           .add(string("\n             :     handler.a:").add(vm.toString(handler.a())))
           .add(string("\n             :     handler.b:").add(vm.toString(handler.b()))));


        // if (seed <= type(uint).max / 100 * 20) {
        //     vm.ffiLog("\n[test] skip by 1 day\n");
        //     skip(1 days);
        // }

        if (handler.a() == 0) { 
            handler.incrementA();
            counter++;

            vm.ffiLog(string("invariant_A(): [post]:")
               .add(string("\n             :       handler:").add(vm.toString(address(handler))))
               .add(string("\n             :     timestamp:").add(vm.toString(block.timestamp)))
               .add(string("\n             :         nonce:").add(vm.toString(counter)))
               .add(string("\n             : handler.nonce:").add(vm.toString(handler.counter())))
               .add(string("\n             :     handler.a:").add(vm.toString(handler.a())))
               .add(string("\n             :     handler.b:").add(vm.toString(handler.b()))));
            return; 
        } 

        assertEq(true, false);
    }


    /// forge-config: default.invariant.runs = 3
    /// forge-config: default.invariant.depth = 10
    /// forge-config: default.invariant.fail-on-revert = true
    /// forge-config: default.invariant.call-override = false
    function invariant_B() external {
        vm.ffiLog(string("invariant_B(): [pre]")
           .add(string("\n             :       handler:").add(vm.toString(address(handler))))
           .add(string("\n             :     timestamp:").add(vm.toString(block.timestamp)))
           .add(string("\n             :         nonce:").add(vm.toString(counter)))
           .add(string("\n             : handler.nonce:").add(vm.toString(handler.counter())))
           .add(string("\n             :     handler.a:").add(vm.toString(handler.a())))
           .add(string("\n             :     handler.b:").add(vm.toString(handler.b()))));


        // if (seed <= type(uint).max / 100 * 20) {
        //     vm.ffiLog("\n[test] skip by 1 day\n");
        //     skip(1 days);
        // }

        if (handler.b() == 0) { 
            handler.incrementB();
            counter++;

            vm.ffiLog(string("invariant_B(): [post]:")
               .add(string("\n             :       handler:").add(vm.toString(address(handler))))
               .add(string("\n             :     timestamp:").add(vm.toString(block.timestamp)))
               .add(string("\n             :         nonce:").add(vm.toString(counter)))
               .add(string("\n             : handler.nonce:").add(vm.toString(handler.counter())))
               .add(string("\n             :     handler.a:").add(vm.toString(handler.a())))
               .add(string("\n             :     handler.b:").add(vm.toString(handler.b()))));
            return; 
        }

        assertEq(true, false);
    }

}
