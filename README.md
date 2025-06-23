## SubastaFlash - Smart Contract

Este es el trabajo final del **Módulo 2**, donde se desarrolla un contrato inteligente para gestionar una **subasta dinámica** con funcionalidades básicas y avanzadas. El contrato está escrito en Solidity y desplegado en la red **Sepolia**.

## Funcionalidades principales

- **Constructor**: inicializa la subasta con un tiempo predefinido.
- **Ofertar**: permite a los usuarios hacer ofertas mayores al 5% de la mejor.
- **Extensión automática**: si una oferta válida llega en los últimos 10 minutos, la subasta se extiende 10 minutos más.
- **Mostrar ganador**: muestra al ganador y el monto de la oferta.
- **Mostrar historial**: se puede consultar todas las ofertas y el historial de cada usuario.
- **Devolver depósitos**: reembolsa a los no-ganadores descontando una comisión del 2%.
- **Reembolso parcial**: permite retirar ofertas anteriores a la última válida mientras la subasta sigue activa.
- **Seguridad y validaciones**: uso de modificadores, `require()` y eventos para robustez.

## 📄 Contrato en Sepolia

-**URL del contrato verificado**: [[Ver en Etherscan](https://sepolia.etherscan.io/address/0x548FE8EEc4163328a98C5249BdB7B748a9B45ADa#writeContract)]

## Requisitos técnicos

- Solidity ^0.8.26
- Compatible con Remix + MetaMask
- Deploy en red Sepolia

## Cómo probar

1. Abrir [Remix IDE](https://remix.ethereum.org)
2. Importar el archivo `FinalProyect.sol`
3. Conectar MetaMask a la red **Sepolia**
4. Compilar con versión `0.8.26`
5. Desplegar contrato desde tu cuenta
6. Probar funciones como:
   - `ofertar()` → enviar ETH (recuerda mínimo +5%)
   - `reembolsoParcial()` → si hiciste más de una oferta
   - `finalizar()` → después de que el tiempo expire
   - `retirar()` → los que no ganaron
   - `verOfertas()` → ver todas las ofertas
   - `verHistorialDe(address)` → historial por usuario

## Eventos

- `NuevaOferta(address oferente, uint monto)`
- `SubastaFinalizada(address ganador, uint monto)`
- `ReembolsoParcial(address oferente, uint monto)`
- `FondosRetirados(address to, uint amount)`

## Consideraciones

- Solo el **owner** puede finalizar la subasta y retirar fondos del contrato.
- Todos los montos están en wei.

## Licencia

Este proyecto está bajo la licencia MIT.
