////////////////////////////////////////////////////////////////////////////////////////////////////

`include "encoder.vh"

////////////////////////////////////////////////////////////////////////////////////////////////////

module enc_buffer (
    input clk,
    input rst_n,
    input CON_PHASE con_phase,
    input [$clog2(RS_COD_LEN) - 1 : 0] con_counter,
    input [ENC_SYM_NUM - 1 : 0][EGF_ORDER - 1 : 0] enc_data,
    output logic buf_enable,
    output logic [$clog2(ENC_SYM_NUM + 1) - 1 : 0] buf_valid,
    output logic [2 * ENC_SYM_NUM - 2 : 0][EGF_ORDER - 1 : 0] buf_data
);

    logic [$clog2(2 * ENC_SYM_NUM - 1) - 1 : 0] buf_counter;
    
    assign buf_enable = (buf_counter - buf_valid < ENC_SYM_NUM);
    
////////////////////////////////////////////////////////////////////////////////////////////////////
    
    always_comb begin
        if (con_phase != CON_WOR) begin
            buf_valid = '0;
        end else if (con_counter < ENC_SYM_NUM) begin
            buf_valid = con_counter;
        end else if (con_counter < RS_MES_LEN) begin
            buf_valid = ENC_SYM_NUM;
        end else if (con_counter < ENC_SYM_NUM + RS_MES_LEN) begin
            buf_valid = RS_MES_LEN + ENC_SYM_NUM - con_counter;
        end else begin
            buf_valid = '0;
        end
    end
    
////////////////////////////////////////////////////////////////////////////////////////////////////

    always_ff @(posedge clk) begin
        if (con_phase == CON_IDL) begin
            buf_counter <= '0;
        end else if (con_counter == RS_COD_LEN) begin
            buf_counter <= con_counter + ENC_SYM_NUM - RS_COD_LEN;
        end else if (buf_enable) begin
            buf_counter <= buf_counter + ENC_SYM_NUM - buf_valid;
        end else if (!buf_enable) begin
            buf_counter <= buf_counter - buf_valid;
        end
    end

////////////////////////////////////////////////////////////////////////////////////////////////////

    always_ff @(posedge clk) begin
        if (con_phase == CON_IDL) begin
            buf_data <= '0;
        end else begin
            for (int i = 2 * ENC_SYM_NUM - 2; i >= 0; i --) begin
                if (i >= 2 * ENC_SYM_NUM + buf_valid - buf_counter - 1) begin
                    buf_data[i] <= buf_data[i - buf_valid];
                end else if (buf_enable && i >= ENC_SYM_NUM + buf_valid - buf_counter - 1) begin
                    buf_data[i] <= enc_data[i + buf_counter + 1 - buf_valid - ENC_SYM_NUM];
                end else begin
                    buf_data[i] <= '0;
                end
            end
        end
    end

endmodule

////////////////////////////////////////////////////////////////////////////////////////////////////