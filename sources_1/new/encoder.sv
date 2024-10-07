////////////////////////////////////////////////////////////////////////////////////////////////////

`include "encoder.vh"

////////////////////////////////////////////////////////////////////////////////////////////////////

module encoder (
    input clk,
    input rst_n,
    input [ENC_SYM_NUM - 1 : 0][EGF_ORDER - 1 : 0] data_in,
    output [2 * ENC_SYM_NUM - 2 : 0][EGF_ORDER - 1 : 0] data_out 
);

    logic [$clog2(RS_COD_LEN) - 1 : 0] con_master_counter;
    logic buf_enable;
    logic [$clog2(ENC_SYM_NUM + 1) - 1 : 0] buf_request;
    logic [2 * ENC_SYM_NUM - 2 : 0][EGF_ORDER - 1 : 0] buf_data;
    
    assign data_out = buf_data;

    enc_controller controller (
        .clk(clk),
        .rst_n(rst_n),
        .con_master_counter(con_master_counter)
    );
    
    enc_buffer buffer (
        .clk(clk),
        .rst_n(rst_n),
        .con_master_counter(con_master_counter),
        .enc_data(data_in),
        .buf_enable(buf_enable),
        .buf_request(buf_request),
        .buf_data(buf_data)
    );
    
    enc_formatter formatter (
        .clk(clk),
        .rst_n(rst_n),
        .con_master_counter(con_master_counter),
        .buf_request(buf_request),
//        .buf_data(buf_data[2 * ENC_SYM_NUM - 2 : ENC_SYM_NUM - 1])
        .buf_data(buf_data)
    );

endmodule

//////////////////////////////////////////////////////////////////////////////////////////////////////