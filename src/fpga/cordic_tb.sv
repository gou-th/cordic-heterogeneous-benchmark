`timescale 1ns / 1ps

module cordic_tb();
    
    //DUT variables
    logic clk;
    logic rst;
    logic btn;
    logic signed [15:0] angle_in;
    logic [15:0] led_out;

    //file variables
    int file_handle;
    int scan_result;
    
    logic signed [15:0] test_angle;
    logic signed [15:0] exp_cos;
    logic signed [15:0] exp_sin;
    
    int diff_cos, diff_sin;
    int tests_run = 0;
    int errors_found = 0;
    
    cordic dut (.clk(clk),.rst(rst),.btn(btn),.angle_in(angle_in),.led_out(led_out));
    initial begin
        clk = 0;
        forever #5 clk=~clk; 
    end

    initial begin
        file_handle=$fopen("test_vectors.txt", "r");       
        if (file_handle==0) begin
            $display("Cannot open file");
            $finish;
        end
        //initial reset
        rst=1;
        angle_in=0;
        #20;
        rst=0;
        #10;
        while (!$feof(file_handle)) begin
            
            //read one line in the form - angle, expected Cosine, expected Sine
            scan_result = $fscanf(file_handle,"%d %d %d\n",test_angle,exp_cos,exp_sin);
            if (scan_result==3) begin
                angle_in = test_angle;               
                //Wait 17 clock cycles for the computation and initial input to finish
                repeat(17) @(posedge clk);
                #1;                
                diff_cos=cos_out-exp_cos;
                diff_sin=sin_out-exp_sin;
                if (diff_cos<-13||diff_cos>13||diff_sin<-13||diff_sin>13) begin
                    $display("Error value: %d", test_angle);
                    $display("Expected cos value: %d, Actual value: %d", exp_cos, cos_out);
                    $display("Expected sine value: %d, Actual value: %d", exp_sin, sin_out);
                    errors_found++;
                end
                tests_run++;
            end
        end
        $fclose(file_handle);        
        $display("File ends");
        $display("Total runs: %d",tests_run);
        $display("Total erros:    %d",errors_found);       
    end

endmodule