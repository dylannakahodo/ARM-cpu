// Program or Instuction Memory -- IM1.V
// Multiplies 3 by 5 and the product is in X4
//
// It works like this:
//    First, the registers are initialized: X2 = 3, X4 = 0
//    X2 will serve as a counter, while X4
//    will serve to store the partial product
//
//    Second, there is a loop, where each pass will decrement
//    the counter X2 by one, and increment the partial product
//    X4 by 5.
//    Note that the loop will pass three times, each time
//    adding 5 to X4.  At the end of the loop, X4 = 3 x 5.
//
module IM(idata,iaddr);

output [15:0] idata;
input  [15:0] iaddr;

reg    [15:0] idata;

always @(iaddr[3:1])
  case(iaddr[3:1])
     0: idata={3'd6, 7'd3, 3'd7, 3'd2};      //L0: ADDI  X2,XZR,#3
     1: idata={3'd0, 3'd7,4'd0,3'd7,3'd4};   //    ADD   X4,XZR,XZR
     2: idata={3'd5, 7'b1111110,3'd0,3'd2};  //L1: CBZ   X2,L0
     3: idata={3'd6, 7'd5, 3'd4,3'd4};       //    ADDI  X4,X4,#5
     4: idata={3'd6, 7'b1111111,3'd2,3'd2};  //    ADDI  X2,X2,#-1
     5: idata={3'd5, 7'b1111101,3'd0,3'd7};  //    CBZ   XZR,L1
     default: idata=0;
  endcase

endmodule