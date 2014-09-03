part of requestful.core;

abstract class RBase{
  RequestFrame query(Map m);
}

class RequestFrame{
  final MapDecorator meta = MapDecorator.create();
  Middleware prefilter,postfilter;
  final Function initFn;
  Completer $future;

  static create(q,n,f,m) => new RequestFrame(q,n,f,m);

  RequestFrame(Map q,Middleare prefn(n),Middleware postfn(n),this.initFn){
    this.prefilter = prefn(this);
    this.postfilter = postfn(this);
    this.$future = new Completer();
    this.meta.add('query',q);

    this.prefilter.ware((r,nxt,end){ nxt(); });
    this.postfilter.ware((r,nxt,end){ nxt(); });
  }

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
