////////////////////////////////////////////////////////////////////////////////////////////////////

`include "encoder.vh"

////////////////////////////////////////////////////////////////////////////////////////////////////

module encoder (
    input clk,
    input rst_n,
    input [ENC_SYM_NUM - 1 : 0][EGF_ORDER - 1 : 0] data_in,
    output logic [2 * ENC_SYM_NUM - 2 : 0][EGF_ORDER - 1 : 0] data_out 
);

    logic [ENC_SYM_NUM - 1 : 0][EGF_ORDER - 1 : 0] data_in_reg;

    logic [$clog2(RS_COD_LEN) - 1 : 0] con_counter;
    
    logic buf_enable;
    logic [$clog2(ENC_SYM_NUM + 1) - 1 : 0] buf_request;
    logic [2 * ENC_SYM_NUM - 2 : 0][EGF_ORDER - 1 : 0] buf_data;
    
    FOR_PHASE for_phase;
    logic [RS_MES_LEN % ENC_SYM_NUM - 1 : 0][EGF_ORDER - 1 : 0] for_half_data;
    logic [ENC_SYM_NUM - 1 : 0][EGF_ORDER - 1 : 0] for_full_data;
    FOR_PHASE for_phase_reg;
    logic [ENC_SYM_NUM - 1 : 0][EGF_ORDER - 1 : 0] for_data_reg;
    
    logic [RS_PAR_LEN - 1 : 0][EGF_ORDER - 1 : 0] pro_data;
    logic [RS_PAR_LEN - 1 : 0][EGF_ORDER - 1 : 0] pro_data_reg;

////////////////////////////////////////////////////////////////////////////////////////////////////

    enc_controller controller (
        .clk(clk),
        .rst_n(rst_n),
        .con_counter(con_counter)
    );
    
    enc_buffer buffer (
        .clk(clk),
        .rst_n(rst_n),
        .con_counter(con_counter),
        .enc_data(data_in_reg),
        .buf_enable(buf_enable),
        .buf_request(buf_request),
        .buf_data(buf_data)
    );
    
    enc_formatter formatter (
        .clk(clk),
        .rst_n(rst_n),
        .con_counter(con_counter),
        .buf_request(buf_request),
        .buf_data(buf_data),
        .for_phase(for_phase),
        .for_half_data(for_half_data),
        .for_full_data(for_full_data)
    );

//    enc_processor processor (
//        .clk(clk),
//        .rst_n(rst_n),
//        .for_phase(for_phase),
//        .for_half_data(for_half_data),
//        .for_full_data(for_full_data),
//        .pro_data(pro_data),
//        .pro_data_reg(pro_data_reg)
//    );

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
        for_phase_reg <= for_phase;
    end

    always_ff @(posedge clk) begin
        if (for_phase == FOR_HAL) begin
            for (int i = RS_MES_LEN % ENC_SYM_NUM - 1; i >= 0; i --) begin
                for_data_reg[i] <= for_half_data[i];
            end
        end else if (for_phase == FOR_FUL) begin
            for (int i = ENC_SYM_NUM - 1; i >= 0; i --) begin
                for_data_reg[i] <= for_full_data[i];
            end
        end else begin
            for (int i = ENC_SYM_NUM - 1; i >= 0; i --) begin
                for_data_reg[i] <= '0;
            end
        end
    end
    
////////////////////////////////////////////////////////////////////////////////////////////////////

    always_ff @(posedge clk) begin
        data_in_reg <= data_in;
    end
    
    always_ff @(posedge clk) begin
        data_out <= {pro_data_reg, pro_data};
    end

endmodule

//////////////////////////////////////////////////////////////////////////////////////////////////////