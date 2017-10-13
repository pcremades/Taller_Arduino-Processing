import hypermedia.net.*;

UDP udp;

void setup(){
  size(640, 480); 
  // Crear conexión UDP
  udp = new UDP(this, 10552); // En este caso se abre el puerto 10522
  //udp.log( true );
  udp.listen( true );  // Escuchar puerto.
}

void draw(){
  
}

void receive( byte[] data, String ip, int port ){
  println(ip);
  println(port);
  println( data );
}