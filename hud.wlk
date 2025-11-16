import wollok.game.*

object barraDeVida {
    // Posición fija en la pantalla (ej. esquina superior izquierda)
    var property position = game.at(1, 23) 
    
    var property image = "100.png" 
    
    method actualizarBarra(vidaActual) {
		const vidaRedondeada = ((vidaActual / 5).round() * 5).max(0).min(100)

        image = vidaRedondeada.toString() + ".png"
    }
}



// --- Objeto para la barra de energía ---
object barraDeEnergia {
	// La ponemos justo debajo de la barra de vida
	var property position = game.at(2, 22) // Abajo
	
	var property image = "E100.png"
	
	method actualizarBarra(energiaActual) {
		// Para no necesitar 100 imágenes, redondeamos la energía
		
		const energiaRedondeada = (energiaActual / 10).round() * 10
		
		//"energia_100.png", "energia_90.png", etc.
		image = "E" + energiaRedondeada.toString() + ".png"
	}
}


// --- Objeto para la barra de Vida del BOSS ---
object barraVidaBoss {
   
    var property position = game.at(10, 23) 
    

    var property image = "bossBar_frame.png" 
    

    var vidaActual = 100
    var vidaMaxima = 100
    

    method setearVidaMaxima(maxima) {
        vidaMaxima = maxima
        self.actualizarBarra(maxima)
    }


    method actualizarBarra(actual) {
        vidaActual = actual.max(0) 
        
     
        const porcentaje = ((vidaActual / vidaMaxima) * 100).round()
 
        const decena = (porcentaje / 10).round() * 10 
        
       
        image = "boss_" + decena.toString() + ".png"
    }
}