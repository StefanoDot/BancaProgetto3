@isTest
public with sharing class AmmontareInLettereTest {

    @isTest static void testCurrencyToWordsFormat(){
        double nr = 1857.01;
        Decimal num = 263.5;
        test.startTest();
        AmmontareInLettere.CurrencyToWordsFormat(12587);
                AmmontareInLettere.CurrencyToWordsFormat(nr);
                        AmmontareInLettere.CurrencyToWordsFormat(num);

        test.stopTest();

    }
    
    
}