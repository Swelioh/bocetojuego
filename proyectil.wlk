import protagonista.*
class Proyectil {
    var property image = "proyectil.png"
    var property position = game.at(0, 0)
    var property velocidadY = -0.25
    const danio
    const posX
    const posY

    method spawnear() {
        position = game.at(posX, posY)
        game.addVisual(self)
    }

    method actualizar(nombreEnemigo) {
        position = position.up(velocidadY)
        const posProtagonista = protagonista.position()
        // Si el proyectil sale de la pantalla, se elimina
        if (self.position().distance(posProtagonista) < 3) {
            protagonista.restarVida(danio)
            protagonista.recibirEmpujon(nombreEnemigo)
            game.removeVisual(self)
        }
    }

    method estaFueraDePantalla() = position.y() < 0
}