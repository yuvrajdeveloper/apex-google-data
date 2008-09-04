public class TranslateService {
    public integer responseStatus { get { return integer.valueof( json.get('responseStatus') ); } } 
    public string responseDetails { get { return json.get('responseDetails'); } } 
   	public string translatedText { get { return json.get('translatedText'); } } 
    
    map<string,string> json = new map<string,string>();
    public integer debug { get; set; } { debug = 1; } 
	string uri = 'http://ajax.googleapis.com/ajax/services/language/translate';
	
	// use: http://ajax.googleapis.com/ajax/services/language/translate?v=1.0&q=hello%20world&langpair=en%7Cit
	
	GoogleService service = new GoogleService('translate');
    
    public googledata getfeed( string url) {
    	service.getFeedMethod('GET',url,null, null);
    	if (debug > 1) system.debug( service.response.getBody() );
    	return parseResponse( service.response.getBody() ); 
    } 
    
    private googledata parseResponse(string body ) { 
    	
		body = body.replaceAll('\\\\u0026#39;','\''); // are there others?
    		
    	list<string> ttt = new list<string>();
    	for ( string a : body.split('["\\{\\}]') ) { 
    		a = a.trim(); 
    		if ( a != null && a != '' && a != ':' && a != ',' && a != 'responseData') { 
    			a = a.replaceAll(': ','');
    			a = a.replaceAll(',$','');
    			ttt.add(a);    
    		} 
    	} 
    
    	json.clear();
    	for ( integer i = 0; i < ttt.size(); i++ )  {
    		json.put(ttt[i].trim(),ttt[i+1].trim());
    		i++;
    	}
		
    	if (debug > 1) { 
    		system.debug(json);
    		for(string key : json.keyset()) { 
    			system.debug( key + ' -> '+json.get(key) );
    		}
    	}
    	system.assert( json.get('responseStatus') != null ,'missing responseStatus');
    	
    	return new GoogleData( new xmldom('<entry><translatedText>'+json.get('translatedText')+'</translatedText></entry>') );
    }
    
    public googledata translate (string origin,string pair ) {
    	system.assert( origin.length() <= 500 , ' Google terms of service restrict to 500 chars');   
    	return this.getFeed( uri + '?v=1.0&q=' + EncodingUtil.urlEncode( origin, 'UTF-8') 
    	 + '&langpair='  + EncodingUtil.urlEncode( pair, 'UTF-8' ) );
    }
    
  	/* 
 	 * test methods below here
 	 */
 	public static testMethod void t5() { 
 		TranslateService s = new TranslateService();
 		s.debug = 3;
 		string ss = 'Edge, founded in 1998, is a start-up based in Austin, TX. The company designs and manufactures a device to convert music from one digital format to another. Edge sells its product through retailers and its own website.';
 		// s.translate(ss,'en|it');
       	
 	
 		s.parseResponse(	'{"responseData": {"translatedText":"Edge, fondata nel 1998, è una start-up con sede a Austin, TX. L&#39;azienda progetta e produce un dispositivo per convertire la musica digitale da un formato ad un altro. Edge vende i suoi prodotti attraverso rivenditori al dettaglio e il suo sito web."}, "responseDetails": null, "responseStatus": 200}'
	);
 		system.debug( s.translatedText );
    	system.debug( s.responseStatus ); 
    	system.debug( s.responseDetails ); 
 	}
 	
 	public static testMethod void t4() { 
 		TranslateService s = new TranslateService();
 		s.debug = 3;
 		s.parseResponse('{"responseData"  :   {"translatedText":  "Ciao mondo"  }, "responseDetails": null, "responseStatus": 200 }');
   		system.debug( s.translatedText );
    	system.debug( s.responseStatus ); 
    	system.debug( s.responseDetails ); 
 	}
  	
  	public static testMethod void t3() { 
        TranslateService s = new TranslateService();
        s.debug = 3;
        s.translate('This is important','en|xx'); // should error
       	
       	system.debug( s.translatedText );
       	system.assert( s.translatedText == null, ' expected no translation');
    	system.debug( s.responseStatus ); 
    	system.assert( s.responseStatus == 400 , ' expected invalid lang pair'); 
    	system.debug( s.responseDetails ); 
    	system.assert( s.responseDetails == 'invalid translation language pair' , ' expected invalid lang pair'); 
    	
    } 
    
    public static testMethod void t2() { 
        TranslateService s = new TranslateService();
        s.translate('This is important','en|it');
       	
       	system.debug( s.translatedText );
    	system.debug( s.responseStatus ); // 200 is ok
    	system.debug( s.responseDetails ); // null is ok	
    }    
    
    public static testMethod void t1() { 
        TranslateService s = new TranslateService();
        
        googledata t = s.getFeed('http://ajax.googleapis.com/ajax/services/language/translate?v=1.0&q=hello%20world&langpair=en%7Cit' );
    	
    	system.debug(t);
    	system.debug( t.entries[0].getValue('translatedText') );
    	system.debug( s.translatedText );
    	system.debug( s.responseStatus ); // 200 is ok
    	system.debug( s.responseDetails ); // null is ok	
     } 
}