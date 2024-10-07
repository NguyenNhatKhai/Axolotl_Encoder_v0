////////////////////////////////////////////////////////////////////////////////////////////////////

`include "encoder.vh"

////////////////////////////////////////////////////////////////////////////////////////////////////

module enc_selector (
    input clk,
    input rst_n,
    input CON_PHASE con_phase,
    input [$clog2(RS_COD_LEN) - 1 : 0] con_counter,
    input [$clog2(ENC_SYM_NUM + 1) - 1 : 0] buf_valid,
    input [ENC_SYM_NUM - 1 : 0][EGF_ORDER - 1 : 0] buf_data,
    input [ENC_SYM_NUM - 1 : 0][EGF_ORDER - 1 : 0] pro_data,
    input [ENC_SYM_NUM - 1 : 0][EGF_ORDER - 1 : 0] pro_data_reg,
    output logic [ENC_SYM_NUM - 1 : 0][EGF_ORDER - 1 : 0] sel_data
);
    
////////////////////////////////////////////////////////////////////////////////////////////////////

    always_ff @(posedge clk) begin
        if (con_phase != CON_WOR) begin
            sel_data <= '0;
        end else if (con_counter < ENC_SYM_NUM) begin
            for (int i = ENC_SYM_NUM - 1; i >= 0; i --) begin
                if (i >= buf_valid) begin
                    sel_data[i] <= pro_data_reg[i - buf_valid];
                end else begin
                    sel_data[i] <= buf_data[i + ENC_SYM_NUM - buf_valid];
                end
            end
        end else if (con_counter < RS_MES_LEN) begin
            sel_data <= buf_data;
        end else if (con_counter < ENC_SYM_NUM + RS_MES_LEN) begin
            for (int i = ENC_SYM_NUM - 1; i >= 0; i --) begin
                if (i >= ENC_SYM_NUM - buf_valid) begin
                    sel_data[i] <= buf_data[i];
                end else begin
                    sel_data[i] <= pro_data[i + buf_valid];
                end
            end
        end else if (con_counter <= RS_COD_LEN) begin
            sel_data <= pro_data;
        end else begin
            sel_data <= '0;
        end
    end

endmodule