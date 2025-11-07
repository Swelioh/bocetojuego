import wollok.game.*
import mapas.*
import protagonista.*
import enemigos.*
import hud.*

object controlacion {
    // --- Nombres constantes para los timers ---
    const nombreTickGeneral = "actualizacion general"
    const nombreTickEnemigos = "actualizacion enemigos"

    method configuracionControles() {
        // CONTROLES DE TECLADO (sin cambios)
        keyboard.right().onPressDo({ => protagonista.moverDerecha() })
        keyboard.left().onPressDo({ => protagonista.moverIzquierda() })
        keyboard.up().onPressDo({ => protagonista.intentarSaltar() })
        keyboard.q().onPressDo({ => protagonista.atacar() })
        keyboard.n().onPressDo({ => mapa.siguienteMapa() })
        keyboard.w().onPressDo({ protagonista.alternarEscudo() })
        
        // --- GAME TICKS ---
        
        // Detener timers antiguos si existen
        self.detenerTimers()

        // Iniciar nuevos timers usando los nombres constantes
        game.onTick(50, nombreTickGeneral, { => protagonista.actualizar() })
        game.onTick(50, nombreTickEnemigos, { mapa.mapaActual().listaEnemigos().forEach({ enemigo => enemigo.actualizar() })})
    }
    
    // --- MÉTODO DETENER (MODIFICADO) ---
    method detenerTimers() {
        game.removeTickEvent(nombreTickGeneral)
        game.removeTickEvent(nombreTickEnemigos)
    }
}