`timescale 1ns/10ps
module IOTDF( clk, rst, in_en, iot_in, fn_sel, busy, valid, iot_out);
input          clk;
input          rst;
input          in_en;
input  [7:0]   iot_in;
input  [2:0]   fn_sel;
output         busy;
output         valid;
output [127:0] iot_out;

parameter MAX = 3'b001;
parameter MIN = 3'b010;
parameter AVG = 3'b011;
parameter EXTRACT = 3'b100;
parameter EXCLUDE = 3'b101;
parameter PEAK_MAX = 3'b110;
parameter PEAK_MIN = 3'b111;

parameter EXTRACT_LOW = 128'h6fff_ffff_ffff_ffff_ffff_ffff_ffff_ffff;
parameter EXTRACT_HIGH = 128'hafff_ffff_ffff_ffff_ffff_ffff_ffff_ffff;
parameter EXCLUDE_LOW = 128'h7fff_ffff_ffff_ffff_ffff_ffff_ffff_ffff;
parameter EXCLUDE_HIGH = 128'hBfff_ffff_ffff_ffff_ffff_ffff_ffff_ffff;

integer i;

reg valid_w, valid_r;
reg [7:0] iot_out_w [0:15];
reg [7:0] iot_out_r [0:15];

assign busy = 0;
assign valid = valid_r;

reg [3:0] byte_counter_w, byte_counter_r;
reg [2:0] round_counter_w, round_counter_r;
reg [1:0] compare_w, compare_r;

reg [130:0] avg_w, avg_r;

assign iot_out = (fn_sel==AVG) ? avg_r[130:3] :
                 {iot_out_r[ 0], iot_out_r[ 1], iot_out_r[ 2], iot_out_r[ 3], 
                  iot_out_r[ 4], iot_out_r[ 5], iot_out_r[ 6], iot_out_r[ 7], 
                  iot_out_r[ 8], iot_out_r[ 9], iot_out_r[10], iot_out_r[11], 
                  iot_out_r[12], iot_out_r[13], iot_out_r[14], iot_out_r[15]};

reg peak_w, peak_r;
reg peak_min_start_w, peak_min_start_r;
reg peak_min_first_round_w, peak_min_first_round_r;


always @(*) begin
    valid_w = valid_r;
    for (i=0; i<16; i=i+1) begin
        iot_out_w[i] = iot_out_r[i];
    end
    byte_counter_w = byte_counter_r;
    round_counter_w = round_counter_r;
    compare_w = compare_r;
    avg_w = avg_r;
    peak_w = peak_r;
    peak_min_start_w = peak_min_start_r;
    peak_min_first_round_w = peak_min_first_round_r;

    case(fn_sel)
        MAX: begin
            if (in_en) begin
                byte_counter_w = byte_counter_r + 1;
                round_counter_w = (byte_counter_r == 4'd15) ? round_counter_r + 1 : round_counter_r;
                valid_w = ( (round_counter_r==3'd7) && (byte_counter_r==4'd15) ) ? 1 : 0;
                if (compare_r == 0) begin
                    if (byte_counter_r==4'd15) begin
                        compare_w = 0;
                    end
                    else if (iot_in==iot_out_r[byte_counter_r]) begin
                        compare_w = 0;
                    end
                    else if (iot_in>iot_out_r[byte_counter_r]) begin
                        compare_w = 1;
                    end
                    else begin
                        compare_w = 2;
                    end
                end
                else begin
                    compare_w = (byte_counter_r==4'd15) ? 0 : compare_r;
                end
                if ( round_counter_r == 0 ) begin
                    iot_out_w[byte_counter_r] = iot_in;
                end
                else begin
                    case(compare_r)
                        0: iot_out_w[byte_counter_r] = (iot_in<iot_out_r[byte_counter_r]) ? iot_out_r[byte_counter_r] : iot_in;
                        1: iot_out_w[byte_counter_r] = iot_in;
                        default: iot_out_w[byte_counter_r] = iot_out_r[byte_counter_r];
                    endcase
                end
            end
            else begin
                valid_w = valid_r;
                byte_counter_w = byte_counter_r;
                round_counter_w = round_counter_r;
                for (i=0; i<16; i=i+1) begin
                    iot_out_w[i] = iot_out_r[i];
                end
                compare_w = compare_r;
            end
            avg_w = avg_r;
            peak_w = peak_r;
            peak_min_start_w = peak_min_start_r;
            peak_min_first_round_w = peak_min_first_round_r;
        end
        MIN: begin
            if (in_en) begin
                byte_counter_w = byte_counter_r + 1;
                round_counter_w = (byte_counter_r == 4'd15) ? round_counter_r + 1 : round_counter_r;
                valid_w = ( (round_counter_r==3'd7) && (byte_counter_r==4'd15) ) ? 1 : 0;
                if (compare_r == 0) begin
                    if (byte_counter_r==4'd15) begin
                        compare_w = 0;
                    end
                    else if (iot_in==iot_out_r[byte_counter_r]) begin
                        compare_w = 0;
                    end
                    else if (iot_in>iot_out_r[byte_counter_r]) begin
                        compare_w = 1;
                    end
                    else begin
                        compare_w = 2;
                    end
                end
                else begin
                    compare_w = (byte_counter_r==4'd15) ? 0 : compare_r;
                end
                if ( round_counter_r == 0 ) begin
                    iot_out_w[byte_counter_r] = iot_in;
                end
                else begin
                    case(compare_r)
                        0: iot_out_w[byte_counter_r] = (iot_in<iot_out_r[byte_counter_r]) ? iot_in : iot_out_r[byte_counter_r];
                        1: iot_out_w[byte_counter_r] = iot_out_r[byte_counter_r];
                        default: iot_out_w[byte_counter_r] = iot_in;
                    endcase
                end
            end
            else begin
                valid_w = valid_r;
                byte_counter_w = byte_counter_r;
                round_counter_w = round_counter_r;
                for (i=0; i<16; i=i+1) begin
                    iot_out_w[i] = iot_out_r[i];
                end
                compare_w = compare_r;
            end
            avg_w = avg_r;
            peak_w = peak_r;
            peak_min_start_w = peak_min_start_r;
            peak_min_first_round_w = peak_min_first_round_r;
        end
        AVG: begin
            if (in_en) begin
                byte_counter_w = byte_counter_r + 1;
                round_counter_w = (byte_counter_r == 4'd15) ? round_counter_r + 1 : round_counter_r;
                valid_w = ( (round_counter_r==3'd7) && (byte_counter_r==4'd15) ) ? 1 : 0;
                compare_w = compare_r;
                iot_out_w[byte_counter_r] = iot_in;
                if ( (round_counter_r==3'd0) && (byte_counter_r==4'd0) ) begin
                    avg_w = 0;
                end
                else begin
                    avg_w = (byte_counter_r==4'd15) ? avg_r + {iot_out_r[ 0], iot_out_r[ 1], iot_out_r[ 2], iot_out_r[ 3], 
                                                               iot_out_r[ 4], iot_out_r[ 5], iot_out_r[ 6], iot_out_r[ 7], 
                                                               iot_out_r[ 8], iot_out_r[ 9], iot_out_r[10], iot_out_r[11], 
                                                               iot_out_r[12], iot_out_r[13], iot_out_r[14], iot_in        } : avg_r;
                end
            end
            else begin
                valid_w = valid_r;
                byte_counter_w = byte_counter_r;
                round_counter_w = round_counter_r;
                for (i=0; i<16; i=i+1) begin
                    iot_out_w[i] = iot_out_r[i];
                end
                compare_w = compare_r;
                avg_w = avg_r;
            end
            peak_w = peak_r;
            peak_min_start_w = peak_min_start_r;
            peak_min_first_round_w = peak_min_first_round_r;
        end
        EXTRACT: begin
            if (in_en) begin
                byte_counter_w = byte_counter_r + 1;
                round_counter_w = (byte_counter_r == 4'd15) ? round_counter_r + 1 : round_counter_r;
                valid_w = ( ({iot_out[127:8], iot_in}>EXTRACT_LOW) && ({iot_out[127:8], iot_in}<EXTRACT_HIGH) && (byte_counter_r==4'd15) ) ? 1 : 0;
                compare_w = compare_r;
                iot_out_w[byte_counter_r] = iot_in;
            end
            else begin
                valid_w = valid_r;
                byte_counter_w = byte_counter_r;
                round_counter_w = round_counter_r;
                for (i=0; i<16; i=i+1) begin
                    iot_out_w[i] = iot_out_r[i];
                end
                compare_w = compare_r;
            end
            avg_w = avg_r;
            peak_w = peak_r;
            peak_min_start_w = peak_min_start_r;
            peak_min_first_round_w = peak_min_first_round_r;
        end
        EXCLUDE: begin
            if (in_en) begin
                byte_counter_w = byte_counter_r + 1;
                round_counter_w = (byte_counter_r == 4'd15) ? round_counter_r + 1 : round_counter_r;
                valid_w = ( (({iot_out[127:8], iot_in}<EXCLUDE_LOW)||({iot_out[127:8], iot_in}>EXCLUDE_HIGH)) && (byte_counter_r==4'd15) ) ? 1 : 0;
                compare_w = compare_r;
                iot_out_w[byte_counter_r] = iot_in;
            end
            else begin
                valid_w = valid_r;
                byte_counter_w = byte_counter_r;
                round_counter_w = round_counter_r;
                for (i=0; i<16; i=i+1) begin
                    iot_out_w[i] = iot_out_r[i];
                end
                compare_w = compare_r;
            end
            avg_w = avg_r;
            peak_w = peak_r;
            peak_min_start_w = peak_min_start_r;
            peak_min_first_round_w = peak_min_first_round_r;
        end
        PEAK_MAX: begin
            if (in_en) begin
                byte_counter_w = byte_counter_r + 1;
                round_counter_w = (byte_counter_r == 4'd15) ? round_counter_r + 1 : round_counter_r;
                valid_w = ( (round_counter_r==3'd7) && (byte_counter_r==4'd15) && (peak_r||((compare_r==0)&&(iot_in>iot_out_r[byte_counter_r]))) ) ? 1 : 0;
                if (compare_r == 0) begin
                    if (byte_counter_r==4'd15) begin
                        compare_w = 0;
                    end
                    else if (iot_in==iot_out_r[byte_counter_r]) begin
                        compare_w = 0;
                    end
                    else if (iot_in>iot_out_r[byte_counter_r]) begin
                        compare_w = 1;
                    end
                    else begin
                        compare_w = 2;
                    end
                end
                else begin
                    compare_w = (byte_counter_r==4'd15) ? 0 : compare_r;
                end
                case(compare_r)
                    0: iot_out_w[byte_counter_r] = (iot_in<iot_out_r[byte_counter_r]) ? iot_out_r[byte_counter_r] : iot_in;
                    1: iot_out_w[byte_counter_r] = iot_in;
                    default: iot_out_w[byte_counter_r] = iot_out_r[byte_counter_r];
                endcase
                if ( (round_counter_r==3'd7) && (byte_counter_r==4'd15) ) begin
                    peak_w = 0;
                end
                else begin
                    if ( (compare_r==0) && (iot_in>iot_out_r[byte_counter_r]) ) begin
                        peak_w = 1;
                    end
                    else begin
                        peak_w = peak_r;
                    end
                end
            end
            else begin
                valid_w = valid_r;
                byte_counter_w = byte_counter_r;
                round_counter_w = round_counter_r;
                for (i=0; i<16; i=i+1) begin
                    iot_out_w[i] = iot_out_r[i];
                end
                compare_w = compare_r;
                peak_w = peak_r;
            end
            avg_w = avg_r;
            peak_min_start_w = peak_min_start_r;
            peak_min_first_round_w = peak_min_first_round_r;
        end
        PEAK_MIN: begin
            if (in_en) begin
                byte_counter_w = byte_counter_r + 1;
                round_counter_w = (byte_counter_r == 4'd15) ? round_counter_r + 1 : round_counter_r;
                valid_w = ( (round_counter_r==3'd7) && (byte_counter_r==4'd15) && ((peak_r||((compare_r==0)&&(iot_in<iot_out_r[byte_counter_r])))||peak_min_first_round_r) ) ? 1 : 0;
                if (compare_r == 0) begin
                    if (byte_counter_r==4'd15) begin
                        compare_w = 0;
                    end
                    else if (iot_in==iot_out_r[byte_counter_r]) begin
                        compare_w = 0;
                    end
                    else if (iot_in>iot_out_r[byte_counter_r]) begin
                        compare_w = 1;
                    end
                    else begin
                        compare_w = 2;
                    end
                end
                else begin
                    compare_w = (byte_counter_r==4'd15) ? 0 : compare_r;
                end
                peak_min_start_w = (byte_counter_r == 4'd15) ? 0 : peak_min_start_r;
                peak_min_first_round_w = ( (round_counter_r==3'd7) && (byte_counter_r==4'd15) ) ? 0 : peak_min_first_round_r;
                if (peak_min_start_r) begin
                    iot_out_w[byte_counter_r] = iot_in;
                end
                else begin
                    case(compare_r)
                        0: iot_out_w[byte_counter_r] = (iot_in<iot_out_r[byte_counter_r]) ? iot_in : iot_out_r[byte_counter_r];
                        1: iot_out_w[byte_counter_r] = iot_out_r[byte_counter_r];
                        default: iot_out_w[byte_counter_r] = iot_in;
                    endcase
                end
                if ( (round_counter_r==3'd7) && (byte_counter_r==4'd15) ) begin
                    peak_w = 0;
                end
                else begin
                    if ( (compare_r==0) && (iot_in<iot_out_r[byte_counter_r]) ) begin
                        peak_w = 1;
                    end
                    else begin
                        peak_w = peak_r;
                    end
                end
            end
            else begin
                valid_w = valid_r;
                byte_counter_w = byte_counter_r;
                round_counter_w = round_counter_r;
                for (i=0; i<16; i=i+1) begin
                    iot_out_w[i] = iot_out_r[i];
                end
                compare_w = compare_r;
                peak_w = peak_r;
                peak_min_start_w = peak_min_start_r;
                peak_min_first_round_w = peak_min_first_round_r;
            end
            avg_w = avg_r;
        end
        default: begin
            valid_w = valid_r;
            byte_counter_w = byte_counter_r;
            round_counter_w = round_counter_r;
            for (i=0; i<16; i=i+1) begin
                iot_out_w[i] = iot_out_r[i];
            end
            compare_w = compare_r;
            avg_w = avg_r;
            peak_w = peak_r;
            peak_min_start_w = peak_min_start_r;
            peak_min_first_round_w = peak_min_first_round_r;
        end
    endcase
end



always @(posedge clk or posedge rst) begin
    if (rst) begin
        valid_r <= 0;
        for (i=0; i<16; i=i+1) begin
            iot_out_r[i] <= 0;
        end
        byte_counter_r <= 0;
        round_counter_r <= 0;
        compare_r <= 0;
        // avg_r <= 0;
        peak_r <= 0;
        peak_min_start_r <= 1;
        peak_min_first_round_r <= 1;
    end
    else begin
        valid_r <= valid_w;
        for (i=0; i<16; i=i+1) begin
            iot_out_r[i] <= iot_out_w[i];
        end
        byte_counter_r <= byte_counter_w;
        round_counter_r <= round_counter_w;
        compare_r <= compare_w;
        // avg_r <= avg_w;
        peak_r <= peak_w;
        peak_min_start_r <= peak_min_first_round_w;
        peak_min_first_round_r <= peak_min_first_round_w;
    end
end


wire en_avg;
assign en_avg = (fn_sel==AVG);
wire gclk_avg;
assign gclk_avg = (clk & en_avg);
always @(posedge gclk_avg or posedge rst) begin
    if (rst) begin
        avg_r <= 0;
    end
    else begin
        avg_r <= avg_w;
    end
end

// wire en_peak;
// assign en_peak = (fn_sel==PEAK_MAX || fn_sel==PEAK_MIN);
// wire gclk_peak;
// assign gclk_peak = (clk & en_peak);
// always @(posedge gclk_peak or posedge rst) begin
//     if (rst) begin
//         peak_r <= 0;
//     end
//     else begin
//         peak_r <= peak_w;
//     end
// end


endmodule
