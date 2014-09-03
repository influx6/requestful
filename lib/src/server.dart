library requestful.core;

import 'dart:core';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:hub/hub.dart';
import 'package:path/path.dart' as path;

part 'base.dart';

class Requestful extends RequestfulBase{
  final HttpClient client = new HttpClient();

  static create([m]) => new Requestful(m);

  Requestful([m]): super(m);

  RequestFrame query(Map m){
   this.processQuery(m);

   var frame = RequestFrame.create(m,(fr){
      return Middleware.create((n){
        n.close().then((res){
          fr.postfilter.emit(res);
        });
      });
    },(fr){
      return Middleware.create((n){
        var data = [];
        n.listen((d){
          data.addAll(d is List ? d : [d]);
        },onDone:(){
          if(!fr.$future.isCompleted) 
            return fr.$future.complete(UTF8.decode(data));
        },onError:(e){
          if(!fr.$future.isCompleted) 
            return fr.$future.completeError(e);
        });

      });
    },(fr){
      this.client.openUrl(m['with'],m['url']).then((req){
        fr.prefilter.emit(req);
      },onError:fr.$future.completeError);
    });

    frame.meta.add('req',client);
    return frame;
  }

  void validateQuery(Map m){
    if(!m.containsKey('to') && !m.containsKey('with'))
      throw """
        Configuration maps format are as follows:
        {
          'to': http://localhost:3010/client.dart
          'with':'get'
          'data': '';
          'headers':{
            'etag': 12132323
          }
        }
      """;
  }
}
