`timescale 1ns / 1ps
`define EOF 32'hFFFF_FFFF
`define NULL 0

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Enginputeer: 
// 
// Create Date: 04/11/2020 10:50:46 AM
// Design Name: 
// Module Name: axi_file_loader
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module axi_file_loader #
(
    parameter filename = "rule.bin",
    parameter address_width = 16,
    parameter data_width = 32
)
(
        input m_axi_aclk,
        input m_axi_aresetn,

        output [address_width-1:0] m_axi_awaddr,
        output [7:0] m_axi_awlen,
        output [2:0] m_axi_awsize,
        output [1:0] m_axi_awburst,
        output m_axi_awlock,
        output [3:0] m_axi_awcache,
        output [2:0] m_axi_awprot,
        output m_axi_awvalid,
        input m_axi_awready,
        output [data_width*8-1:0] m_axi_wdata,
        output [data_width-1:0] m_axi_wstrb,
        output m_axi_wlast,
        output m_axi_wvalid,
        input m_axi_wready,
        input [1:0] m_axi_bresp,
        input m_axi_bvalid,
        output m_axi_bready,
        output [address_width-1:0] m_axi_araddr,
        output [7:0] m_axi_arlen,
        output [2:0] m_axi_arsize,
        output [1:0] m_axi_arburst,
        output m_axi_arlock,
        output [3:0] m_axi_arcache,
        output [2:0] m_axi_arprot,
        output m_axi_arvalid,
        input m_axi_arready,
        input [data_width*8-1:0] m_axi_rdata,
        input [1:0] m_axi_rresp,
        input m_axi_rlast,
        input m_axi_rvalid,
        output m_axi_rready,

        output reg cfg_prepared
);

    reg [address_width-1:0] m_axi_awaddr_buf = 0;
    reg [7:0] m_axi_awlen_buf = 0;
    reg [2:0] m_axi_awsize_buf = 0;
    reg [1:0] m_axi_awburst_buf = 0;
    reg m_axi_awlock_buf = 0;
    reg [3:0] m_axi_awcache_buf = 0;
    reg [2:0] m_axi_awprot_buf = 0;
    reg m_axi_awvalid_buf = 0;
    reg [data_width*8-1:0] m_axi_wdata_buf = 0;
    reg [data_width-1:0] m_axi_wstrb_buf = 0;
    reg m_axi_wlast_buf = 0;
    reg m_axi_wvalid_buf = 0;
    reg m_axi_bready_buf = 1;
    reg [address_width-1:0] m_axi_araddr_buf = 0;
    reg [7:0] m_axi_arlen_buf = 0;
    reg [2:0] m_axi_arsize_buf = 0;
    reg [1:0] m_axi_arburst_buf = 0;
    reg m_axi_arlock_buf = 0;
    reg [3:0] m_axi_arcache_buf = 0;
    reg [2:0] m_axi_arprot_buf = 0;
    reg m_axi_arvalid_buf = 0;
    reg m_axi_rready_buf = 1;
    reg cfg_prepared_buf = 0;

    assign m_axi_awaddr = m_axi_awaddr_buf;
    assign m_axi_awlen = m_axi_awlen_buf;
    assign m_axi_awsize = m_axi_awsize_buf;
    assign m_axi_awburst = m_axi_awburst_buf;
    assign m_axi_awlock = m_axi_awlock_buf;
    assign m_axi_awcache = m_axi_awcache_buf;
    assign m_axi_awprot = m_axi_awprot_buf;
    assign m_axi_awvalid = m_axi_awvalid_buf;
    assign m_axi_wdata = m_axi_wdata_buf;
    assign m_axi_wstrb = m_axi_wstrb_buf;
    assign m_axi_wlast = m_axi_wlast_buf;
    assign m_axi_wvalid = m_axi_wvalid_buf;
    assign m_axi_bready = m_axi_bready_buf;
    assign m_axi_araddr = m_axi_araddr_buf;
    assign m_axi_arlen = m_axi_arlen_buf;
    assign m_axi_arsize = m_axi_arsize_buf;
    assign m_axi_arburst = m_axi_arburst_buf;
    assign m_axi_arlock = m_axi_arlock_buf;
    assign m_axi_arcache = m_axi_arcache_buf;
    assign m_axi_arprot = m_axi_arprot_buf;
    assign m_axi_arvalid = m_axi_arvalid_buf;
    assign m_axi_rready = m_axi_rready_buf;

    integer data_file,rv,i=0,j,k,enb = 1;
    reg [7:0] buffer;
    reg [address_width-1:0] address = 0;

initial begin
    cfg_prepared = 0;
    m_axi_awsize_buf = $clog2(data_width);
    data_file = $fopen(filename,"rb");
    if (!data_file) begin
        $display("data_file handle was NULL");
    end else begin
        $display("normal!");
    end
    @(posedge m_axi_aresetn);
    #100 ;
    @(posedge m_axi_aclk);
    while (enb) begin
        @(posedge m_axi_aclk);
        m_axi_awvalid_buf = 1;
        m_axi_wvalid_buf = 1;
        m_axi_wlast_buf = 1;
        m_axi_awaddr_buf = address;
        for (i = 0;i < data_width;i = i+1) begin
            rv = $fread(buffer,data_file);
            if (rv < 1)
                enb = 0;

            if(enb!=0) begin
                m_axi_wstrb_buf[i] = 1;
                m_axi_wdata_buf[8*i+7-:8] = buffer;
            end else begin
                m_axi_wstrb_buf[i] = 0;
                m_axi_wdata_buf[8*i+7-:8] = 0;
            end
        end
        @(posedge m_axi_aclk);
        address = address + data_width;
        m_axi_awvalid_buf = 0;
        m_axi_wvalid_buf = 0;
        m_axi_wlast_buf = 0;
        @(posedge m_axi_bvalid);
        @(posedge m_axi_aclk);
    end
    @(posedge m_axi_aclk);
    cfg_prepared = 1;
    $fclose(data_file);
end

endmodule
