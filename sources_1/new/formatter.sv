////////////////////////////////////////////////////////////////////////////////////////////////////

`include "encoder.vh"

////////////////////////////////////////////////////////////////////////////////////////////////////

module enc_formatter (
    input clk,
    input rst_n,
    input [$clog2(RS_COD_LEN) - 1 : 0] con_counter,
    input [$clog2(ENC_SYM_NUM + 1) - 1 : 0] buf_request,
    input [2 * ENC_SYM_NUM - 2 : 0][EGF_ORDER - 1 : 0] buf_data,
    output FOR_PHASE for_phase,
    output logic [RS_MES_LEN % ENC_SYM_NUM - 1 : 0][EGF_ORDER - 1 : 0] for_half_data,
    output logic [ENC_SYM_NUM - 1 : 0][EGF_ORDER - 1 : 0] for_full_data
);

    logic [$clog2(ENC_SYM_NUM) - 1 : 0] for_offset;
    logic [ENC_SYM_NUM - 2 : 0][EGF_ORDER - 1 : 0] for_data_reg;
    
////////////////////////////////////////////////////////////////////////////////////////////////////

    always_comb begin
        if (con_counter < ENC_SYM_NUM && con_counter >= RS_MES_LEN % ENC_SYM_NUM) begin
            for_offset = con_counter - RS_MES_LEN % ENC_SYM_NUM;
        end else if (con_counter < ENC_SYM_NUM) begin
            for_offset = con_counter;
        end else if (con_counter < RS_MES_LEN + ENC_SYM_NUM) begin
            for_offset = con_counter + ENC_SYM_NUM - RS_MES_LEN % ENC_SYM_NUM;
        end else begin
            for_offset = '0;
        end
    end

////////////////////////////////////////////////////////////////////////////////////////////////////

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            for (int i = ENC_SYM_NUM - 2; i >= 0; i --) begin
                for_data_reg[i] <= '0;
            end
        end else begin
            for (int i = ENC_SYM_NUM - 2; i >= 0; i --) begin
                if (i >= ENC_SYM_NUM - for_offset - 1 && for_offset <= buf_request) begin
                    for_data_reg[i] <= buf_data[i + ENC_SYM_NUM + for_offset - buf_request];
                end else if (i >= ENC_SYM_NUM - for_offset - 1) begin
                    for_data_reg[i] <= buf_data[i + ENC_SYM_NUM - buf_request];
                end else begin
                    for_data_reg[i] <= '0;
                end
            end
        end
    end
    
////////////////////////////////////////////////////////////////////////////////////////////////////

    always_comb begin
        if (con_counter < RS_MES_LEN % ENC_SYM_NUM) begin
            for_phase = FOR_IDL;
        end else if (con_counter < ENC_SYM_NUM + RS_MES_LEN % ENC_SYM_NUM) begin
            for_phase = FOR_HAL;
        end else if (con_counter < RS_MES_LEN + ENC_SYM_NUM) begin
            for_phase = FOR_FUL;
        end else begin
            for_phase = FOR_IDL;
        end
    end

////////////////////////////////////////////////////////////////////////////////////////////////////
    
    always_comb begin
        for (int i = RS_MES_LEN % ENC_SYM_NUM - 1; i >= 0; i --) begin
            if (i + for_offset >= ENC_SYM_NUM) begin
                for_half_data[i] = for_data_reg[i + ENC_SYM_NUM - RS_MES_LEN % ENC_SYM_NUM - 1];
            end else if (for_offset <= buf_request) begin
                for_half_data[i] = buf_data[i + for_offset + 2 * ENC_SYM_NUM - buf_request - 1];
            end else begin
                for_half_data[i] = buf_data[i + 2 * ENC_SYM_NUM - buf_request - 1];
            end
        end
    end

////////////////////////////////////////////////////////////////////////////////////////////////////

    always_comb begin
        for (int i = ENC_SYM_NUM - 1; i >= 0; i --) begin
            if (i + for_offset >= ENC_SYM_NUM) begin
                for_full_data[i] = for_data_reg[i - 1];
            end else begin
                for_full_data[i] = buf_data[i + for_offset + ENC_SYM_NUM - 1];
            end
        end
    end

endmodule

////////////////////////////////////////////////////////////////////////////////////////////////////
