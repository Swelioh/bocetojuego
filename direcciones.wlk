class Movimiento {
    method nombre()

    method empuje()

    method imagenReposo(base) = base + self.nombre() + "Quieto.png"

    method animacionMoviendose(base, cantidad) =
        (1..cantidad).map({ i => base + self.nombre() + "Moviendose" + i + ".png" })

    method imagenSalto(base) =
        base + self.nombre() + "Salto.png"

    method animacionAtacando(base, cantidad) =
        (1..cantidad).map({ i => base + self.nombre() + "Ataque" + i + ".png" })
    
    method imagenBloqueo(base) =
		base + self.nombre() + "Bloqueo.png"

    method imagenDerrotado(base) =
        base + self.nombre() + "Derrotado.png"

    method animacionGolpeado(base, cantidad) =
        (1..cantidad).map({ i => base + self.nombre() + "Golpeado" + i + ".png" })

    method animacionAtacandoAereo(base, cantidad) =
        (1..cantidad).map({ i => base + self.nombre() + "AtaqueAereo" + i + ".png" })

    method mirandoHaciaEnemigo(xProtagonista, xEnemigo) = xEnemigo > xProtagonista
}

class Derecha inherits Movimiento(){
    override method nombre() = "Derecha"
    override method empuje() = 1
}
class Izquierda inherits Movimiento() {
    override method nombre() = "Izquierda"
    override method empuje() = -1
    override method mirandoHaciaEnemigo(xProtagonista, xEnemigo) = xEnemigo < xProtagonista
}

const derecha = new Derecha()
const izquierda = new Izquierda()