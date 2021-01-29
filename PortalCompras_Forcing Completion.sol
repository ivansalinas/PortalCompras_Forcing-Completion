// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract portalcompras_Forcing_Completion {
    
address payable public owner;
producto[16]   productos;

struct producto {
    
    address payable  comprador;
	uint256  estado; //1 pago, 2 enviado,3 entregado
    uint256  Fecha_pago;
    uint256  Fecha_envio;
    uint256  Fecha_recepcion;
}

constructor() payable public {
require(msg.value == 80.00 ether);
owner = msg.sender;

}

function Compra (uint256 id_producto) external payable {
    require(id_producto >= 0 && id_producto <= 15);
    require(productos[id_producto].comprador == address(0x0));
    require(msg.value == 6.00 ether);
    productos[id_producto]= producto(msg.sender,1,block.timestamp,0,0);
}

function envio(uint256 id_producto) public {
    require(id_producto >= 0 && id_producto <= 15);
    require(msg.sender == owner);
    require(productos[id_producto].estado==1);
    productos[id_producto].estado= 2;
    productos[id_producto].Fecha_envio=block.timestamp;
}

function confirma_entrega(uint256 id_producto) external payable {
    require(id_producto >= 0 && id_producto <= 15);
    require(productos[id_producto].comprador == msg.sender);
    require(productos[id_producto].estado==2);
    productos[id_producto].estado= 3;
    productos[id_producto].Fecha_recepcion=block.timestamp;
    productos[id_producto].comprador.transfer(5 ether);
    owner.transfer(6 ether);

}

function resuelve_conflictos  (uint256 id_producto) external payable {
    require(id_producto >= 0 && id_producto <= 15);
    require(productos[id_producto].comprador == msg.sender || msg.sender == owner);
    
        if (block.timestamp  > (productos[id_producto].Fecha_pago + 1 minutes) && productos[id_producto].estado == 1 ) {
            productos[id_producto].comprador.transfer(6 ether);
            address(0x0).transfer(5 ether);
            owner.transfer(6 ether);  
            productos[id_producto].comprador=address(0x0);
        
        } else if (block.timestamp  > (productos[id_producto].Fecha_envio + 1 minutes) && productos[id_producto].estado == 2 ) {
        
            address(0x0).transfer(5 ether);
            owner.transfer(5 ether);   
        }
        
    }

 }