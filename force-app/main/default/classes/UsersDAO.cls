/**
 * Created by Matteo Tornielli on 04/04/2019.
 */

public without sharing class UsersDAO {

    public static List<User> getUsersFromIds(List<String> queriedFields, Set<String> userIds) {
       // system.debug('UserDAO getUserFromIds - Start');
        String query = 'SELECT ';
        for(String field: queriedFields) {
            query += field+', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM User WHERE Id in :userIds';
        List<User> users = (List<User>) Database.query(query);
        if(users != null && !users.isEmpty()) {
         //   system.debug('return: ' + users);
           // system.debug('UserDAO getUserFromIds - End');
            return users;
        } else {
            //system.debug('return: ' + new List<User>());
            //system.debug('UserDAO getUserFromIds - End');
            return new List<User>();
        }
    }
}