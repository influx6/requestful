library tagdb.spec;

import 'dart:io';
import 'dart:async';
import 'package:requestful/server.dart';
import 'package:hub/hub.dart';
import 'package:rio/rio.dart';

void main(){

  var rio = Rio.create();
  var pack = new RegExp(r'^/packages|^packages');

  rio.on('get',(r){
    Funcs.when(pack.hasMatch(r.url),(){
      r.sendFile('..${r.url}');
      r.end();
    });
  });

  rio.on('get',(r){
    Funcs.when(Valids.match(r.url,'/love.txt'),(){
      r.sendFile('../web/love.txt');
      r.end();
    });
  });

  rio.on('get',(r){
    Funcs.when(Valids.match(r.url,'/client.dart'),(){
      r.sendFile('../web/client.dart');
      r.end();
    });
  });

  rio.on('get',(r){
    Funcs.when(Valids.match(r.url,'/client.dart.js'),(){
      r.sendFile('../web/client.dart.js');
      r.end();
    });
  });

  rio.on('get',(r){
    Funcs.when(Valids.match(r.url,'/'),(){
      r.sendFile('../web/index.html');
      r.end();
   });
  });

  rio.on('get',(r){
    Funcs.when(Valids.match(r.url,'/favicon.ico'),(){
      r.sendText('');
      r.end();
   });
  });

  var io;

  HttpServer.bind('127.0.0.1',3010).then((server){
    io = server;
    server.listen((r){
      rio.use(r);
    });
  });


  jazzUp((_){

    _.group('testing requestful',($){

      var rd = Requestful.create({});

      $.test('requestful created')
      .rack('is it valid',(f){
          Expects.asserts(f,rd);
      }).emit(rd);

      rd = null;

      $.test('requestful destroyed')
      .rack('it should be null',(f){
          Expects.asserts(f,true);
      }).emit(Valids.notExist(rd));

    });

    _.group('make request to server',($){

      var rd = Requestful.create({});

      $.test('requests')
      .rackAsync('request client.dart',(f,next){
        var client = rd.query({
          'to':'http://localhost:3010/client.dart',
          'with':'get'
        });
        client.init().then((n) => next()).catchError((e){
          throw e;
          next();
        });

      })
     .rackAsync('request root',(f,next){

          var root = rd.query({
            'to':'http://localhost:3010/',
            'with':'get'
          });
          root.init().then((n) => next()).catchError((e){
            throw e;
            next();
          });

      }).emit(rd);

    });


  });

}
