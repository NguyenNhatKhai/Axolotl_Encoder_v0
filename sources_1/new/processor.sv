////////////////////////////////////////////////////////////////////////////////////////////////////

`include "encoder.vh"

////////////////////////////////////////////////////////////////////////////////////////////////////

function logic [EGF_ORDER - 1 : 0] egf_mul (
    input [EGF_ORDER - 1 : 0] data_in_0,
    input [EGF_ORDER - 1 : 0] data_in_1
);

    logic redundant_bit;
    logic [EGF_ORDER - 1 : 0] returned_data;
    redundant_bit = '0;
    returned_data = '0;

    for (int i = 0; i < EGF_ORDER; i ++) begin
        redundant_bit = returned_data[EGF_ORDER - 1];
        for (int j = EGF_ORDER - 1; j >= 0; j --) begin
            returned_data[j] = returned_data[j - 1] ^ (redundant_bit & EGF_PRI_POL[j]) ^ (data_in_0[j] & data_in_1[EGF_ORDER - i - 1]);
        end
        returned_data[0] = (redundant_bit & EGF_PRI_POL[0]) ^ (data_in_0[0] & data_in_1[EGF_ORDER - i - 1]);
    end
    
    return returned_data;

endfunction

////////////////////////////////////////////////////////////////////////////////////////////////////

module enc_processor (
    input clk,
    input rst_n,
    input FOR_PHASE for_phase,
    input [RS_MES_LEN % ENC_SYM_NUM - 1 : 0][EGF_ORDER - 1 : 0] for_half_data,
    input [ENC_SYM_NUM - 1 : 0][EGF_ORDER - 1 : 0] for_full_data,
    output logic [RS_PAR_LEN - 1 : 0][EGF_ORDER - 1 : 0] pro_data,
    output logic [RS_PAR_LEN - 1 : 0][EGF_ORDER - 1 : 0] pro_data_reg
);
    
////////////////////////////////////////////////////////////////////////////////////////////////////

    always_ff @(posedge clk) begin
        if (for_phase == FOR_IDL) begin
            for (int i = RS_PAR_LEN - 1; i >= 0; i --) begin
                pro_data_reg[i] <= '0;
            end
        end else if (for_phase == FOR_HAL) begin
            for (int i = RS_PAR_LEN - 1; i >= 0; i --) begin
                pro_data_reg[i] <= pro_data[i];
            end
        end else if (for_phase == FOR_FUL) begin
            for (int i = RS_PAR_LEN - 1; i >= 0; i --) begin
                pro_data_reg[i] <= pro_data[i];
            end
        end else begin
            for (int i = RS_PAR_LEN - 1; i > 0; i --) begin
                pro_data_reg[i] <= pro_data_reg[i - 1];
            end
            pro_data_reg[0] <= '0;
        end
    end
    
////////////////////////////////////////////////////////////////////////////////////////////////////

    logic [RS_PAR_LEN - 1 : 0][EGF_ORDER - 1 : 0] pro_data_temp;
    
    always_comb begin
        for (int i = RS_PAR_LEN - 1; i >= 0; i --) begin
            pro_data_temp[i] = pro_data_reg[i];
        end
        if (for_phase == FOR_HAL) begin
            for (int i = RS_MES_LEN % ENC_SYM_NUM - 1; i >= 0; i --) begin
                for (int j = RS_PAR_LEN - 1; j > 0; j --) begin
                    pro_data[j] = pro_data_temp[j - 1] ^ egf_mul(for_half_data[i] ^ pro_data_temp[RS_PAR_LEN - 1], RS_GEN_POL[j]);
                end
                pro_data[0] = egf_mul(for_half_data[i] ^ pro_data_temp[RS_PAR_LEN - 1], RS_GEN_POL[0]);
                for (int j = RS_PAR_LEN - 1; j >= 0; j --) begin
                    pro_data_temp[j] = pro_data[j];
                end
            end
        end else if (for_phase == FOR_FUL) begin
            for (int i = ENC_SYM_NUM - 1; i >= 0; i --) begin
                for (int j = RS_PAR_LEN - 1; j > 0; j --) begin
                    pro_data[j] = pro_data_temp[j - 1] ^ egf_mul(for_full_data[i] ^ pro_data_temp[RS_PAR_LEN - 1], RS_GEN_POL[j]);
                end
                pro_data[0] = egf_mul(for_full_data[i] ^ pro_data_temp[RS_PAR_LEN - 1], RS_GEN_POL[0]);
                for (int j = RS_PAR_LEN - 1; j >= 0; j --) begin
                    pro_data_temp[j] = pro_data[j];
                end
            end
        end
    end

endmodule