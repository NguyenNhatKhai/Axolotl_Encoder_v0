////////////////////////////////////////////////////////////////////////////////////////////////////

`include "encoder.vh"

////////////////////////////////////////////////////////////////////////////////////////////////////

module enc_buffer (
    input clk,
    input rst_n,
    input [$clog2(RS_COD_LEN) - 1 : 0] con_counter,
    input [ENC_SYM_NUM - 1 : 0][EGF_ORDER - 1 : 0] enc_data,
    output logic buf_enable,
    output logic [$clog2(ENC_SYM_NUM + 1) - 1 : 0] buf_request,
    output logic [2 * ENC_SYM_NUM - 2 : 0][EGF_ORDER - 1 : 0] buf_data
);

    logic [$clog2(2 * ENC_SYM_NUM - 1) - 1 : 0] buf_counter;
    
    assign buf_enable = (buf_counter - buf_request < ENC_SYM_NUM);
    
////////////////////////////////////////////////////////////////////////////////////////////////////
    
    always_comb begin
        if (con_counter == '0) begin
            buf_request = '0;
        end else if (con_counter < ENC_SYM_NUM) begin
            buf_request = con_counter;
        end else if (con_counter < RS_MES_LEN) begin
            buf_request = ENC_SYM_NUM;
        end else if (con_counter < ENC_SYM_NUM + RS_MES_LEN) begin
            buf_request = RS_MES_LEN + ENC_SYM_NUM - con_counter;
        end else if (con_counter <= RS_COD_LEN) begin
            buf_request = '0;
        end else begin
            buf_request = '0;
        end
    end
    
////////////////////////////////////////////////////////////////////////////////////////////////////

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            buf_counter <= '0;
        end else if (con_counter == RS_COD_LEN) begin
            buf_counter <= con_counter + ENC_SYM_NUM - RS_COD_LEN;
        end else if (buf_enable) begin
            buf_counter <= buf_counter + ENC_SYM_NUM - buf_request;
        end else if (!buf_enable) begin
            buf_counter <= buf_counter - buf_request;
        end
    end

////////////////////////////////////////////////////////////////////////////////////////////////////

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            for (int i = 2 * ENC_SYM_NUM - 2; i >= 0; i --) begin
                buf_data[i] <= '0;
            end
        end else begin
            for (int i = 2 * ENC_SYM_NUM - 2; i >= 0; i --) begin
                if (i >= 2 * ENC_SYM_NUM + buf_request - buf_counter - 1) begin
                    buf_data[i] <= buf_data[i - buf_request];
                end else if (buf_enable && i >= ENC_SYM_NUM + buf_request - buf_counter - 1) begin
                    buf_data[i] <= enc_data[i + buf_counter + 1 - buf_request - ENC_SYM_NUM];
                end else begin
                    buf_data[i] <= '0;
                end
            end
        end
    end

endmodule

////////////////////////////////////////////////////////////////////////////////////////////////////