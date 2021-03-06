#encoding: utf-8

class MasBeneficioEn
  def initialize(destino_esperado)
    @destino_esperado = destino_esperado
  end
  def matches?(emprendedor)
    @emprendedor = emprendedor
    @emprendedor.maximo_beneficio_en?.eql?(@destino_esperado)
  end
  def failure_message
    "esperabamos obtener un  mayor beneficio en #{@destino_esperado} pero lo hemos obtenido en #{@emprendedor.maximo_beneficio_en?}"
  end
  def negative_failure_message
    "no esperabamos obtener un  mayor beneficio en #{@destino_esperado} pero es donde lo hemos obtenido"
  end
end

def vender_en(expected)
  MasBeneficioEn.new expected
end

Given /^una pequeña furgoneta que es capaz de transportar hasta (\d+) Kg de pescado que cuesta cargar (\d+) euros y que cobra (\d+) euros por kilometro recorrido$/ do |capacidad_maxima, coste_carga, coste_por_kilometro_recorrido|
  @especificaciones_de_la_furgoneta = {:capacidad_maxima => capacidad_maxima.to_i,
                                       :coste_carga => coste_carga.to_i,
                                       :precio_por_kilometro => coste_por_kilometro_recorrido.to_i}
end

Given /^la siguiente cartera de clientes:$/ do |cartera_de_clientes|
  clientes = []
  cartera_de_clientes.rows.each do |descripcion_cliente|
    pescaderia = Pescaderia.new(:ciudad => descripcion_cliente[0],
                                :kilometros_desde_lonja => descripcion_cliente[1].to_i,
                                :oferta => Oferta.new(:vieiras => descripcion_cliente[2].to_i,
                                                      :pulpo => descripcion_cliente[3].to_i,
                                                      :centollos => descripcion_cliente[4].to_i))
    clientes << pescaderia
  end
  @cartera_de_clientes = CarteraDeClientes.new clientes
end

Given /^que la mercancia gallega pierde (\d+)% de calidad por cada 100Km recorridos debido a un defecto en la furgoneta$/ do |porcentaje_cada_cien_kilometros|
  @especificaciones_de_la_furgoneta.merge!(:perdida_de_calidad => porcentaje_cada_cien_kilometros.to_i)
end

When /^compro en la lonja (\d+) Kg de vieiras a (\d+) euros el kilo, (\d+) Kg de pulpo a (\d+) euros el kilo y otros (\d+) Kg de centollos a (\d+) euros el kilo$/ do |kilos_vieiras, precio_kilo_vieiras, kilos_pulpo, precio_kilo_pulpo, kilos_centollos, precio_kilo_centollos|
  @furgoneta = Furgoneta.new(@especificaciones_de_la_furgoneta)
  @emprendedor = Emprendedor.con @cartera_de_clientes, @furgoneta
  carga = Carga.new(:vieiras => kilos_vieiras.to_i,
                    :pulpo => kilos_pulpo.to_i,
                    :centollos => kilos_centollos.to_i)
  @emprendedor.compra carga
end

Then /^para obtener el mayor beneficio debería vender esa carga de pescado y marisco a "([^"]*)"$/ do |destino|
  @emprendedor.should vender_en destino
end
