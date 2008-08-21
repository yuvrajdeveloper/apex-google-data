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
    	list<string> ar = body.split(',');
    	json.clear();
    	for ( string tmp : ar) {
    		tmp = tmp.replaceAll('["\\{\\}]','');
    		string[] jj = tmp.split(':',2); 
    		json.put(jj[0].trim(),jj[1].trim());
    	}
		try { 
    	json.put( json.get('responseData').split(':')[0],json.get('responseData').split(':')[1] );
		} catch (exception e) { } 
    	
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