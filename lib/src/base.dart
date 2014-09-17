part of requestful.core;

abstract class RBase{
  RequestFrame query(Map m);
}

class RequestFrame{
  final MapDecorator meta = MapDecorator.create();
  final MapDecorator filterStore = new MapDecorator<String,Middleware>();
  final Function initFn;
  Completer $future;

  static create(q,f,[m]) => new RequestFrame(q,f,m);

  RequestFrame(Map q,this.initFn,[Function filterFn]){
    this.$future = new Completer();
    this.meta.add('query',q);
    if(Valids.exist(filterFn)) filterFn(this);
  }

  Middleware filter(String n) => this.filterStore.get(n);
  Middleware addfilter(String n, Middleware fn) => this.filterStore.add(n,fn);

  Future init(){
    this.initFn(this);
    return this.$future.future;
  }

  Map get query => this.meta.get('query');

  Future get whenDone => this.$future.future;

}

class RequestfulBase extends RBase{
  MapDecorator conf;

  RequestfulBase([Map m]){
    this.conf = MapDecorator.useMap(Funcs.switchUnless(m,{}));
  }

  //merges the default configurations from the core to the query
  Map prepareQuery(Map m){
    return Enums.merge(this.conf.core,m);
  }

  void processQuery(Map m){
    this.validateQuery(m);
    var doc = this.prepareQuery(m);
    m['url'] = Uri.parse(doc['to']);
  }

  void validateQuery(Map m);


}
