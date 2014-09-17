library spec;

import 'package:requestful/client.dart';
import 'package:hub/hubclient.dart';

void main(){


  jazzUp((_){

    _.group('testing requestful',($){

        var rd = Requestful.create({});

        $.test('checking if requests is created')
        .rack('is it valid',(f,g){
          Expects.asserts(Valids.exist(rd),true);
        }).emit(rd);

    });

    _.group('making ajax requests',($){

        var rd = Requestful.create({});

        $.test('requests a resource')
        .rackAsync('request client.dart with ajax',(f,next,g){
          var frame  = f.query({
            'to':"http://127.0.0.1:3010/client.dart",
            'with':'ajax',
            'method':'get'
          });
          
          frame.init().then((n){
            next();
            Expects.isMap(n);
          });

        }).emit(rd);

    });

    _.group('making cache requests',($){

        var rd = Requestful.create({});

        $.test('requests a resource with cache')
        .rack('request client.dart using cache',(f,g){
          var frame = f.query({
            'to':"http://127.0.0.1:3010/love.txt",
            'with':'ajax',
            'method':'get'
          });

          frame.init().then(print).catchError(print);
        }).emit(rd);
    });

    _.group('making jsonp requests',($){

        var rd = Requestful.create({});

        $.test('requests a resource')
        .rack('request client.dart with jsonp',(f,g){

          var frame = f.query({
            'to':"http://127.0.0.1:3010/love.txt",
            'with':'jsonp',
          });

          frame.init().then(Funcs.tag('p json')).catchError(print);
        }).emit(rd);
    });

  });

}
