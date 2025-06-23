// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract Subasta {
   address public owner;
   address public mejorOferente;
   uint public mejorOferta;

   uint public inicio;
   uint public duracion = 2 minutes;
   bool public finalizada;

   uint public comision = 2;
   uint public ExtencionMinutos = 10;

   struct Oferta{
    address oferente;
    uint monto;
   }

   Oferta[] public ofertasTotales;
   mapping(address=> uint[]) public historialOfertas;
   mapping(address => uint) public depositos;

   event NuevaOferta(address indexed oferente, uint monto);
   event SubastaFinalizada(address ganador, uint monto);
   event ReembolsoParcial(address indexed oferente, uint monto);
   event FondosRetirados(address indexed to, uint amount);

   constructor() {
       owner = msg.sender;
       inicio = block.timestamp;
   }

   modifier subastaActiva() {
       require(!finalizada, "Subasta finalizada");
       require(block.timestamp <= inicio + duracion, "Tiempo terminado");
       _;
   }

   modifier soloOwner() {
       require(msg.sender == owner, "No eres el owner");
       _;
   }

   function ofertar() external payable subastaActiva {
       require(msg.value > 0, "Debes enviar ETH");

       uint total = depositos[msg.sender] + msg.value;
       uint minimoRequerido = mejorOferta + (mejorOferta * 5) / 100;

       require(total >= minimoRequerido, "La oferta debe superar en al menos 5%");
       
       historialOfertas[msg.sender].push(msg.value);
       depositos[msg.sender] = total;
       mejorOferente = msg.sender;
       mejorOferta = total;
       ofertasTotales.push(Oferta(msg.sender, total));

       if(inicio + duracion - block.timestamp <= ExtencionMinutos * 1 minutes)
          duracion += ExtencionMinutos * 1 minutes;

       emit NuevaOferta(msg.sender, total);
   }

    function verOfertas() external view returns (Oferta[] memory) {
        return ofertasTotales;
    }
    
    function verHistorialDe(address usuario) external view returns (uint[] memory) {
        return historialOfertas[usuario];
    }

     function reembolsoParcial() external subastaActiva {
        uint[] storage arr = historialOfertas[msg.sender];
        require(arr.length > 1, "No tienes multiples ofertas");

        uint reembolsable;
        // Sumamos todos menos el último
        for (uint i = 0; i < arr.length - 1; i++) {
            reembolsable += arr[i];
            arr[i] = 0; // evita doble retiro
        }
        require(reembolsable > 0, "Nada que reembolsar");

        // Reducimos depósito y enviamos
        depositos[msg.sender] -= reembolsable;
        payable(msg.sender).transfer(reembolsable);

        emit ReembolsoParcial(msg.sender, reembolsable);
    }

   function finalizar() external soloOwner {
       require(!finalizada, "Ya finalizo");
       require(block.timestamp >= inicio + duracion, "Aun no termina");

       finalizada = true;


        uint comisionCalculada  = (mejorOferta * comision) / 100;
        uint paraGanador  = mejorOferta - comisionCalculada;

        // Transferir comisión al owner
        payable(owner).transfer(comisionCalculada);
        // Transferir resto al ganador
        payable(mejorOferente).transfer(paraGanador);


       emit SubastaFinalizada(mejorOferente, mejorOferta);
   }

   function retirar() external {
       require(finalizada, "Subasta no finalizada");
        require(msg.sender != mejorOferente, "Ganador no puede retirar");

        uint dep = depositos[msg.sender];
        require(dep > 0, "Nada para retirar");

        uint comisionCalculada = (dep * comision) / 100;
        uint neto = dep - comisionCalculada;
        depositos[msg.sender] = 0;

        payable(msg.sender).transfer(neto);
        emit FondosRetirados(msg.sender, neto);
   }

   /// Permite al owner retirar los fondos ganadores
   function retirarFondos() external soloOwner {
       require(finalizada, "Subasta no finalizada");
       require(address(this).balance > 0, "Sin balance disponible");

       uint monto = address(this).balance;
       (bool exito, ) = payable(owner).call{value: monto}("");
       require(exito, "Fallo al transferir al owner");
       emit FondosRetirados(owner, monto);
   }

   /// Retorna los segundos restantes hasta el fin de la subasta
     function tiempoRestante() external view returns (uint) {
        if (finalizada || block.timestamp >= inicio + duracion) {
            return 0;
        }
        return (inicio + duracion) - block.timestamp;
    }

   /// Consulta del balance del contrato
   function verBalance() external view returns (uint) {
       return address(this).balance;
   }
}
