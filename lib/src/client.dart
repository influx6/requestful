library requestful.core;

import 'dart:core';
import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'package:hub/hubclient.dart';
import 'package:path/path.dart' as path;

part 'base.dart';

class RequestAbort extends Exception{
    HttpRequest req;
    Event event;

    RequestAbort(message,this.req,[this.event]): super(message);
    String toString(){
      var buf = new StringBuffer();
      buff.add('Message: ${this.message}');
      buff.write('\n');
      buff.add('Event: ${this.event}');
      buff.write('\n');
      buff.add(this.stackTrace);
      return buff.toString();
    }
}

class RequestDisrupt extends Exception{
    HttpRequest req;
    Event event;

    RequestDisrupt(message,this.req,[this.event]): super(message);
    String toString(){
      var buf = new StringBuffer();
      buff.add('Message: ${this.message}');
      buff.write('\n');
      buff.add('Event: ${this.event}');
      buff.write('\n');
      buff.add(this.stackTrace);
      return buff.toString();
    }
}

class Requestful extends RequestfulBase{

  static create([m]) => new Requestful(m);

  Requestful([m]): super(m);

  void validateQuery(Map m){
    if(!m.containsKey('to') && !m.containsKey('with'))
      throw """
        Configuration maps format are as follows:
        {
          'to': http://localhost:3010/client.dart
          'with':'ajax'
          'data': '';
          'headers':{
            'etag': 12132323
          }
        }
      """;
  }

  RequestFrame _ajax(Map conf){
    var req = new HttpRequest();
    var event = null;

    if(!conf.containsKey('method')){
      conf['method'] = 'get';
      if(conf.containsKey('data') && Valids.exist(conf['data'])){
        conf['method'] = 'post';
      }
    }

    req.onError.listen((e){
      this.$future.completerError(new RequestDisrupt('Disrupted',req,e));
    });

    req.onAbort.listen((e){
      this.$future.completerError(new RequestAbort('Aborted',req,e));
    });

    var frame = RequestFrame.create(conf,(fr){
      return Middleware.create((n){
        req.onReadyStateChange.listen((e){
         event = e;
         var status = req.status;
         if(req.readyState == 4){
           if(status >= 200 || status <= 300 || status == 304)
             return fr.postfilter.emit(req);
         }
        });
        req.send(conf['data']);
      });
    },(fr){
      return Middleware.create((n){
          if(fr.$future.isCompleted) return null;
          var text = req.responseText,
              xml = req.responseXml;

          var data = Valids.exist(xml) ? xml : text;
          fr.$future.complete({
            'state':true,
            'event': event,
            'req': req,
            'data': data,
          });
      });
    },(fr){
      fr.prefilter.emit(req);
    });

    req.open(conf['method'],conf['url'].toString());
    frame.meta.add('req',req);
    return frame;
  }

  RequestFrame _jsonp(Map conf){
    var ft = new Completer();
    var callbackId = Hub.randomString(2).replaceAll('-','_');
    var script = new Element.tag('script');
    var cid = ['callback',callbackId].join('_');
    var url = [conf['url'].toString(),'callback=${cid}'].join('&');

    script.attributes['cid'] = cid;

    var frame = RequestFrame.create(conf,(fr){
      return Middleware.create((n){
        window.document.querySelector('head').append(script);
      });
    },(fr){
      return Middleware.create((n){
        fr.$future.complete(n);
      });
    },(fr){
      fr.prefilter.emit(script);
    });

    ft.future.then(frame.postfilter.emit).catchError((e){
      frame.$future.completeError(e);
    });

    frame.whenDone.then((k){
      stripjs.unset('root',cid);
    });

    stripjs.set('root',cid,(data){
      try{
        ft.complete(stripjs.toDartJSON(data));
      }catch(e){
        ft.completeError(e);
      }
    });

    script.src = url;
    frame.meta.add('req',script);
    return frame;
  }

  RequestFrame query(Map m){
   this.processQuery(m);
   if(Valids.match(m['with'],'ajax')) return this._ajax(m);
   if(Valids.match(m['with'],'jsonp')) return this._jsonp(m);
   return null;
  }

}
