module ssdec(
input logic [8:0] result,
output logic [13:0] segments
);

logic [3:0] lsd, msd;
assign lsd = result[3:0];
assign msd = result[7:4];

  always_comb 
  begin
    case(msd)
      4'b0000: begin
               segments[13:7] = 7'b0111111;
      end
      4'b0001: begin segments[13:7] = 7'b0000110;
      end
      4'b0010: begin segments[13:7] = 7'b1011011;
      end
      4'b0011: begin segments[13:7] = 7'b1001111;
      end
      4'b0100: begin segments[13:7] = 7'b1100110;
      end
      4'b0101: begin segments[13:7] = 7'b1101101;
      end
      4'b0110: begin segments[13:7] = 7'b1111101;
      end
      4'b0111: begin segments[13:7] = 7'b0000111;
      end
      4'b1000: begin segments[13:7] = 7'b1111111;
      end
      4'b1001: begin segments[13:7] = 7'b1101111;
      end
      default: begin segments[13:7] = 7'b0;
      end
    endcase
  end

always_comb 
  begin
    case(lsd)
      4'b0000: begin
               segments[6:0] = 7'b0111111;
      end
      4'b0001: begin segments[6:0] = 7'b0000110;
      end
      4'b0010: begin segments[6:0] = 7'b1011011;
      end
      4'b0011: begin segments[6:0] = 7'b1001111;
      end
      4'b0100: begin segments[6:0] = 7'b1100110;
      end
      4'b0101: begin segments[6:0] = 7'b1101101;
      end
      4'b0110: begin segments[6:0] = 7'b1111101;
      end
      4'b0111: begin segments[6:0] = 7'b0000111;
      end
      4'b1000: begin segments[6:0] = 7'b1111111;
      end
      4'b1001: begin segments[6:0] = 7'b1101111;
      end
      default: begin segments[6:0] = 7'b0;
      end
    endcase
  end

endmodule