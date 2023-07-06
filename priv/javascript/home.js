

function cargarProductos(){

    fetch("/home",
    { method: "GET"
    , headers: {"Content-Type": "application/json"}
    })
  .then((response) => {console.log("Data:",response);})
  .catch(error => alert('Caught Exception: ' + error.description));
 
    var productos = JSON.parse(localStorage.getItem("productos"));
    console.log("productos",productos)
    const orders = productos[0].orders;
    var capa = document.getElementById("ordenes");

   orders.map(function(data) {
        var div = document.createElement("div");
        var div2 = document.createElement("div");
        var div3 = document.createElement("div");
        var div4 = document.createElement("div");

        var url = document.createElement("img");
        var nombre = document.createElement("input");
        var desc = document.createElement("textarea");
        var precio = document.createElement("input");
        var eliminar= document.createElement("button");
        var editar = document.createElement("button");
        var pPrecio = document.createElement("p");

        var pValor = document.createElement("p");
        var pId = document.createElement("p");

        pPrecio.innerText = "Precio: $ ";
        pValor.innerText = "Total: $ ";


        eliminar.setAttribute("id","eliminarP");
        editar.setAttribute("id","editarP");
        eliminar.setAttribute("class","btn_eliminar");
        eliminar.innerHTML="Cancelar";
        editar.innerHTML="Pagar";
        editar.setAttribute("class","btn_editar");

        nombre.setAttribute("class","producto-nombre");
        desc.setAttribute("class","producto-desc");
        precio.setAttribute("class","producto-precio");

        precio.setAttribute("id","productoP");

        div.setAttribute("class","content-producto");
        div2.setAttribute("class","content-descripcionP");
        div3.setAttribute("class","content-valoresP");
        

        div4.setAttribute("class","content-botonesP");
        div4.setAttribute("id",data.id);

        eliminar.addEventListener("click",eliminarProducto);
        editar.addEventListener("click",editarProducto);
        precio.addEventListener("keyup",valorTEditar);

        pId.setAttribute("class","idP");
        pId.setAttribute("id","idProducto");

        url.setAttribute("class","img-Producto");
        url.setAttribute("id","img"+data.id);
        url.setAttribute("width","150px");
        url.setAttribute("heigth","250px");

        url.addEventListener("click",cambiarImagen);

        
            url.src = data.imagen;
            pId.innerText=data.id;
            nombre.value = data.nombre;
            desc.value = data.descripcion;
            precio.value = data.precio;
    
            pPrecio.appendChild(precio);
    
            div2.appendChild(pId);
            div2.appendChild(url);
            div2.appendChild(nombre);
            div2.appendChild(desc);
            

            div3.appendChild(pPrecio);
            div4.appendChild(editar);
            div4.appendChild(eliminar);
            
            div.appendChild(div2);
            div.appendChild(div3);
            div.appendChild(div4);
    
            capa.appendChild(div);

        });

}


function eliminarProducto(event){

  var producto =event.currentTarget.parentNode;
  var idProducto = producto.id;
  var productos = JSON.parse(localStorage.getItem("productos"));
  var ordenes = productos[0].orders;
  const index = ordenes.findIndex( x => x.id === idProducto );
  ordenes.splice( index, 1 );

  console.log("Id ",idProducto)
  var data = {
    "orderId" : idProducto
  }

  swal({
      title: "Esta seguro?",
      text: "Desea cancelar la orden de pago?",
      icon: "warning",
      buttons: true,
      dangerMode: true,
    })
    .then((willDelete) => {
      if (willDelete) {
          localStorage.setItem("productos",JSON.stringify(productos));
          fetch("/home", {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(data),
          })
            .then((response) => response.json())
            .catch((error) => alert("Caught Exception: " + error.description));
        swal("Orden Cancelada!", {
          icon: "success",
        });
        setTimeout("redireccionarPagina2()", 1000);
        
      } else {
        swal("No se ha cancelado ninguna orden!");
      }
    });


}


function editarProducto(event){

  var producto =event.currentTarget.parentNode;
  var idProducto = producto.id;
  var productos = JSON.parse(localStorage.getItem("productos"));
  var ordenes = productos[0].orders;
  const index = ordenes.findIndex( x => x.id === idProducto );
  ordenes.splice( index, 1 );

  console.log("Id ",idProducto)

  swal("Seleccione el Método de pago", {
    buttons: {
      cancel: "Salir",
      catch: {
        text: "Efectivo",
        value: "catch",
      },
      defeat: {
        text: "Tarjeta",
        value: "defeat",
      }
    },
  })
  .then((value) => {
    switch (value) {
   
      case "defeat":
        swal("Pago Realizado","Pago Mediante Tarjeta!","success");
        var data = {
          "orderId" : idProducto,
          "metodo": "Tarjeta"
        }
      
        fetch("/home/payment", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify(data),
        })
          .then((response) => response.json())
          .catch((error) => alert("Caught Exception: " + error.description));
          localStorage.setItem("productos",JSON.stringify(productos));
        break;
   
      case "catch":
        swal("Pago Realizado", "Pago Mediante Efectivo!","success");
        var data = {
          "orderId" : idProducto,
          "metodo": "Efectivo"
        }
      
        fetch("/home/payment", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify(data),
        })
          .then((response) => response.json())
          .catch((error) => alert("Caught Exception: " + error.description));
          localStorage.setItem("productos",JSON.stringify(productos));
          
        break;
   
      default:
        swal("Pago Cancelado!");
    }
  });


}


function redireccionarPagina2() {
  window.location = "home";
}



function valorTEditar(event){

  
}
 

 function cambiarImagen(event){
    
    var imagen =event.currentTarget;
    var idImagen = imagen.id;
    console.log(idImagen);
    var productos = JSON.parse(localStorage.getItem("productos"));
    

    swal("Ingrese la url de la nueva imagen", {
        content: "input",
      })
      .then((value) => {
        productos.map(function(data) {
            if("img"+data.id == idImagen){
                data.imagen = value;
                localStorage.setItem("productos",JSON.stringify(productos));
            }
        });
       
        setTimeout("redireccionarPagina2()", 1000);
        
      });
}

 