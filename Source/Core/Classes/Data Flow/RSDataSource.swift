//
//  RSDataSource.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 5/9/18.
//

import UIKit


//Does this protocol define something like a database instance and HealthKit (and even possibly a server in the future)?
//Or maybe this is a query result?
//possibly this is the database and we add another protocol for the query result?
//How can we define a query protocol that would work for both HealthKit and Realm?
//Perhaps the protocol itself only accepts queries formulated in JSON, it's up to the
//concrete object to transform that into a query, submit it, and return query results

//This begs the question as to if we support long running queries w/ update callbacks
//For snapshot queries (e.g., HKSampleQuery), it's easy to bridge HealthKit and Realm
//For now, snapshot queries will most likely be fine, so let's start simply
//We can have ways to refresh a view that just reruns the query

//The question is, can we chain these (i.e., can we map / filter / groupBy / reduce / merge these data sources)?
//A common example will be: get me all the datapoints of these types, merge them, and group them by Date reanges (.e.g, per day, per week)
//Another common example will be: get me all the datapoints of a type, group by some predicate, and aggregate each group (COUNT, MAX, MIN, SUM, AVG, etc)
// How do we define the classes for groupings? Days of the week? Individual days? - typically this is just a function on the datapoint which returns a hashable value

//Some of this chaining will most likely take place at the layout view controller level and will not need to be specified in JSON


//For long running queries, we willproabbly want to use HKAnchoredObjectQuery
//Our assumption is that data points will not be modified, only added / deleted
//In order to support ordered collections (i.e., for tableView / collectionView),
//HK update methods specify data whereas Realm update methods specify
//we will need to specify the indicies of deleted / added data as well as the data themselves,
//However, in the case of realm, we may not want to store all the datapoints in memory
//but this is proabbly premature optimization

//the query results will cache data in memory
//The update handler will include maps of added and deleted points. Maps specify the index of the datapoint in the collection




public protocol RSDataSource  {
    
    //

}
