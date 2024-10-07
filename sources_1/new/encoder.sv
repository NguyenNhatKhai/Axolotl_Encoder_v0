////////////////////////////////////////////////////////////////////////////////////////////////////

`include "encoder.vh"

////////////////////////////////////////////////////////////////////////////////////////////////////

module encoder (
    input clk,
    input rst_n,
    input [ENC_SYM_NUM * EGF_ORDER - 1 : 0] data_in,
    output logic [ENC_SYM_NUM * EGF_ORDER - 1 : 0] data_out
);

    logic [ENC_SYM_NUM - 1 : 0][EGF_ORDER - 1 : 0] data_in_reg;

    CON_PHASE con_phase;
    logic [$clog2(RS_COD_LEN) - 1 : 0] con_counter;
    CON_PHASE con_phase_reg;
    logic [$clog2(RS_COD_LEN) - 1 : 0] con_counter_reg;
    
    logic buf_enable;
    logic [$clog2(ENC_SYM_NUM + 1) - 1 : 0] buf_valid;
    logic [2 * ENC_SYM_NUM - 2 : 0][EGF_ORDER - 1 : 0] buf_data;
    logic [$clog2(ENC_SYM_NUM + 1) - 1 : 0] buf_valid_reg;
    logic [ENC_SYM_NUM : 0][EGF_ORDER - 1 : 0] buf_data_reg;
    
    FOR_PHASE for_phase;
    logic [RS_MES_LEN % ENC_SYM_NUM - 1 : 0][EGF_ORDER - 1 : 0] for_half_data;
    logic [ENC_SYM_NUM - 1 : 0][EGF_ORDER - 1 : 0] for_full_data;
    FOR_PHASE for_phase_reg;
    logic [ENC_SYM_NUM - 1 : 0][EGF_ORDER - 1 : 0] for_data_reg;
    
    logic [RS_PAR_LEN - 1 : 0][EGF_ORDER - 1 : 0] pro_data;
    logic [RS_PAR_LEN - 1 : 0][EGF_ORDER - 1 : 0] pro_data_reg;
    
    logic [ENC_SYM_NUM - 1 : 0][EGF_ORDER - 1 : 0] sel_data;

////////////////////////////////////////////////////////////////////////////////////////////////////

    enc_controller controller (
        .clk(clk),
        .rst_n(rst_n),
        .con_phase(con_phase),
        .con_counter(con_counter)
    );
    
////////////////////////////////////////////////////////////////////////////////////////////////////
    
    enc_buffer buffer (
        .clk(clk),
        .rst_n(rst_n),
        .con_phase(con_phase),
        .con_counter(con_counter),
        .enc_data(data_in_reg),
        .buf_enable(buf_enable),
        .buf_valid(buf_valid),
        .buf_data(buf_data)
    );
    
////////////////////////////////////////////////////////////////////////////////////////////////////
    
    enc_formatter formatter (
        .clk(clk),
        .rst_n(rst_n),
        .con_phase(con_phase),
        .con_counter(con_counter),
        .buf_valid(buf_valid),
        .buf_data(buf_data),
        .for_phase(for_phase),
        .for_half_data(for_half_data),
        .for_full_data(for_full_data)
    );

////////////////////////////////////////////////////////////////////////////////////////////////////

    always_ff @(posedge clk) begin
        for_phase_reg <= for_phase;
    end

    always_ff @(posedge clk) begin
        if (for_phase == FOR_HAL) begin
            for_data_reg[RS_MES_LEN % ENC_SYM_NUM - 1 : 0] <= for_half_data;
        end else if (for_phase == FOR_FUL) begin
            for_data_reg <= for_full_data;
        end else begin
            for_data_reg <= '0;
        end
    end

    enc_processor processor (
        .clk(clk),
        .rst_n(rst_n),
        .for_phase(for_phase_reg),
        .for_half_data(for_data_reg[ RS_MES_LEN % ENC_SYM_NUM - 1 : 0]),
        .for_full_data(for_data_reg),
        .pro_data(pro_data),
        .pro_data_reg(pro_data_reg)
    );
    
////////////////////////////////////////////////////////////////////////////////////////////////////

    always_ff @(posedge clk) begin
        con_phase_reg <= con_phase;
        con_counter_reg <= con_counter;
        buf_valid_reg <= buf_valid;
        buf_data_reg <= buf_data[2 * ENC_SYM_NUM - 2 -: ENC_SYM_NUM];
    end

    enc_selector selector (
        .clk(clk),
        .rst_n(rst_n),
        .con_phase(con_phase_reg),
        .con_counter(con_counter_reg),
        .buf_valid(buf_valid_reg),
        .buf_data(buf_data_reg),
        .pro_data(pro_data[RS_PAR_LEN - 1 -: ENC_SYM_NUM]),
        .pro_data_reg(pro_data_reg[RS_PAR_LEN - 1 -: ENC_SYM_NUM]),
        .sel_data(sel_data)
    );

////////////////////////////////////////////////////////////////////////////////////////////////////

    always_ff @(posedge clk) begin
        for (int i = ENC_SYM_NUM - 1; i >= 0; i --) begin
            data_in_reg[i] <= data_in[(i + 1) * EGF_ORDER - 1 -: EGF_ORDER];
        end
    end
    
    always_comb begin
        for (int i = ENC_SYM_NUM - 1; i >= 0; i --) begin
            data_out[(i + 1) * EGF_ORDER - 1 -: EGF_ORDER] = sel_data[i];
        end
    end

endmodule

//////////////////////////////////////////////////////////////////////////////////////////////////////