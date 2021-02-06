// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract portalcompras_Forcing_Completion {
    
    address payable public vendedor;
    producto[16] productos;
    enum Estado {Pagado, Enviado, Entregado}
    uint256 constant garantia = 5 ether;
    uint256 constant precio = 1 ether;
    
    struct producto {
        address payable comprador;
        Estado  estado;
        uint256 fecha_pago;
        uint256 fecha_envio;
        uint256 fecha_recepcion;
    }
    
    constructor() payable public {
        require(msg.value == productos.length * garantia);
        vendedor = msg.sender;
    }
    
    function productoValido(uint256 id_producto) internal view returns (bool) {
        return id_producto >= 0 && id_producto < productos.length;
    }
    
    function compra(uint256 id_producto) external payable {
        require(productoValido(id_producto));
        require(productos[id_producto].comprador == address(0x0));
        require(msg.value == (precio + garantia));
        productos[id_producto] = producto(msg.sender, Estado.Pagado, block.timestamp, 0, 0);
    }
    
    function envio(uint256 id_producto) public {
        require(productoValido(id_producto));
        require(msg.sender == vendedor);
        require(productos[id_producto].estado == Estado.Pagado);
        productos[id_producto].estado = Estado.Enviado;
        productos[id_producto].fecha_envio = block.timestamp;
    }
    
    function confirma_entrega(uint256 id_producto) external payable {
        require(productoValido(id_producto));
        require(productos[id_producto].comprador == msg.sender);
        require(productos[id_producto].estado == Estado.Enviado);
        productos[id_producto].estado = Estado.Entregado;
        productos[id_producto].fecha_recepcion = block.timestamp;
        productos[id_producto].comprador.transfer(garantia);
        vendedor.transfer(garantia + precio);
    }
    
    function resuelve_conflictos (uint256 id_producto) external payable {
        require(productoValido(id_producto));
        require(productos[id_producto].comprador == msg.sender || msg.sender == vendedor);
        
        if (block.timestamp > (productos[id_producto].fecha_pago + 1 minutes) && productos[id_producto].estado == Estado.Pagado) {
            productos[id_producto].comprador.transfer(garantia + precio);
            address(0x0).transfer(garantia);
            productos[id_producto].comprador = address(0x0);
        
        } else if (block.timestamp  > (productos[id_producto].fecha_envio + 1 minutes) && productos[id_producto].estado == Estado.Enviado) {
            address(0x0).transfer(garantia);
            vendedor.transfer(garantia);   
        }
            
    }
    
 }
