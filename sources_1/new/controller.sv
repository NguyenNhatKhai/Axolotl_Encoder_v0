////////////////////////////////////////////////////////////////////////////////////////////////////

`include "encoder.vh"

////////////////////////////////////////////////////////////////////////////////////////////////////

module enc_controller (
    input clk,
    input rst_n,
    output CON_PHASE con_phase,
    output logic [$clog2(RS_COD_LEN) - 1 : 0] con_counter
);

////////////////////////////////////////////////////////////////////////////////////////////////////

//    always_ff @(posedge clk) begin
//        if (!rst_n) begin
//            con_phase <= CON_IDL;
//        end else if (con_phase == CON_IDL) begin
//            if (rst_n) begin
//                con_phase <= CON_STA;
//            end else begin
//                con_phase <= CON_IDL;
//            end
//        end else if (con_phase == CON_STA) begin
//            con_phase <= CON_WOR;
//        end else if (con_phase == CON_WOR) begin
//            con_phase <= CON_WOR;
//        end else begin
//            con_phase <= CON_IDL;
//        end
//    end
    
////////////////////////////////////////////////////////////////////////////////////////////////////

//    always_ff @(posedge clk) begin
//        if (!rst_n) begin
//            con_counter <= '0;
//        end else if (con_phase == CON_STA) begin
//            con_counter <= ENC_SYM_NUM;
//        end else if (con_phase == CON_WOR) begin
//            if (con_counter + ENC_SYM_NUM > RS_COD_LEN) begin
//                con_counter <= con_counter + ENC_SYM_NUM - RS_COD_LEN;
//            end else begin
//                con_counter <= con_counter + ENC_SYM_NUM;
//            end
//        end else begin
//            con_counter <= '0;
//        end
//    end

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            con_counter <= '0;
        end else if (con_counter + ENC_SYM_NUM > RS_COD_LEN) begin
            con_counter <= con_counter + ENC_SYM_NUM - RS_COD_LEN;
        end else begin
            con_counter <= con_counter + ENC_SYM_NUM;
        end
    end

endmodule

////////////////////////////////////////////////////////////////////////////////////////////////////