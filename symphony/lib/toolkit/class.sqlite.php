<?php

/**
 * The SQlite class acts as a wrapper for connecting to the Database
 * in Symphony. It utilises sqlite3 functions in PHP to complete the usual
 * querying. As well as the normal set of insert, update, delete and query
 * functions, some convenience functions are provided to return results
 * in different ways. Symphony uses a prefix to namespace it's tables in a
 * database, allowing it play nice with other applications installed on the
 * database. An errors that occur during a query throw a `DatabaseException`.
 * By default, Symphony logs all queries to be used for Profiling and Debug
 * devkit extensions when a Developer is logged in. When a developer is not
 * logged in, all queries and errors are made available with delegates.
 *
 * Author: Leonid Verhovskij - l.verhovskij@gmail.com
 * Date: 27.07.2015
 */

class SQLite extends MySQL{
    //Override mysqli functions with sqlite equivalents
    /**
     * Determines if a connection has been made to the MySQL server
     *
     * @return boolean
     */
    public static function isConnected()
    {
        try {
            $connected = (
                isset(self::$_connection['id'])
                && !is_null(self::$_connection['id'])
                && mysqli_ping(self::$_connection['id'])
            );
        } catch (Exception $ex) {
            return false;
        }

        return $connected;
    }

    /**
     * Called when the script has finished executing, this closes the MySQL
     * connection
     *
     * @return boolean
     */
    public function close()
    {
        if ($this->isConnected()) {
            return mysqli_close(self::$_connection['id']);
        }
    }

    /**
     * Creates a connect to the database server given the credentials. If an
     * error occurs, a `DatabaseException` is thrown, otherwise true is returned
     *
     * @param string $host
     *  Defaults to null, which MySQL assumes as localhost.
     * @param string $user
     *  Defaults to null
     * @param string $password
     *  Defaults to null
     * @param string $port
     *  Defaults to 3306.
     * @param null $database
     * @throws DatabaseException
     * @return boolean
     */
    public function connect($host = null, $user = null, $password = null, $port = '3306', $database = null)
    {
        self::$_connection = array(
            'host' => $host,
            'user' => $user,
            'pass' => $password,
            'port' => $port,
            'database' => $database
        );

        try {
            self::$_connection['id'] = mysqli_connect(
                self::$_connection['host'],
                self::$_connection['user'],
                self::$_connection['pass'],
                self::$_connection['database'],
                self::$_connection['port']
            );

            if (!$this->isConnected()) {
                $this->__error('connect');
            }
        } catch (Exception $ex) {
            $this->__error('connect');
        }

        return true;
    }

    /**
     * This will set the character encoding of the connection for sending and
     * receiving data. This function will run every time the database class
     * is being initialized. If no character encoding is provided, UTF-8
     * is assumed.
     *
     * @link http://au2.php.net/manual/en/function.mysql-set-charset.php
     * @param string $set
     *  The character encoding to use, by default this 'utf8'
     */
    public function setCharacterEncoding($set = 'utf8')
    {
        mysqli_set_charset(self::$_connection['id'], $set);
    }

    /**
     * This function will clean a string using the `mysqli_real_escape_string` function
     * taking into account the current database character encoding. Note that this
     * function does not encode _ or %. If `mysqli_real_escape_string` doesn't exist,
     * `addslashes` will be used as a backup option
     *
     * @param string $value
     *  The string to be encoded into an escaped SQL string
     * @return string
     *  The escaped SQL string
     */
    public static function cleanValue($value)
    {
        if (function_exists('mysqli_real_escape_string') && self::isConnected()) {
            return mysqli_real_escape_string(self::$_connection['id'], $value);
        } else {
            return addslashes($value);
        }
    }

    /**
     * Takes an SQL string and executes it. This function will apply query
     * caching if it is a read operation and if query caching is set. Symphony
     * will convert the `tbl_` prefix of tables to be the one set during installation.
     * A type parameter is provided to specify whether `$this->_lastResult` will be an array
     * of objects or an array of associative arrays. The default is objects. This
     * function will return boolean, but set `$this->_lastResult` to the result.
     *
     * @uses PostQueryExecution
     * @param string $query
     *  The full SQL query to execute.
     * @param string $type
     *  Whether to return the result as objects or associative array. Defaults
     *  to OBJECT which will return objects. The other option is ASSOC. If $type
     *  is not either of these, it will return objects.
     * @throws DatabaseException
     * @return boolean
     *  True if the query executed without errors, false otherwise
     */
    public function query($query, $type = "OBJECT")
    {
        if (empty($query) || self::isConnected() === false) {
            return false;
        }

        $start = precision_timer();
        $query = trim($query);
        $query_type = $this->determineQueryType($query);
        $query_hash = md5($query.$start);

        if (self::$_connection['tbl_prefix'] !== 'tbl_') {
            $query = preg_replace('/tbl_(\S+?)([\s\.,]|$)/', self::$_connection['tbl_prefix'].'\\1\\2', $query);
        }

        // TYPE is deprecated since MySQL 4.0.18, ENGINE is preferred
        if ($query_type == self::__WRITE_OPERATION__) {
            $query = preg_replace('/TYPE=(MyISAM|InnoDB)/i', 'ENGINE=$1', $query);

        } elseif ($query_type == self::__READ_OPERATION__ && !preg_match('/^SELECT\s+SQL(_NO)?_CACHE/i', $query)) {
            if ($this->isCachingEnabled()) {
                $query = preg_replace('/^SELECT\s+/i', 'SELECT SQL_CACHE ', $query);
            } else {
                $query = preg_replace('/^SELECT\s+/i', 'SELECT SQL_NO_CACHE ', $query);
            }
        }

        $this->flush();
        $this->_lastQuery = $query;
        $this->_lastQueryHash = $query_hash;
        $this->_result = mysqli_query(self::$_connection['id'], $query);
        $this->_lastInsertID = mysqli_insert_id(self::$_connection['id']);
        self::$_query_count++;

        if (mysqli_error(self::$_connection['id'])) {
            $this->__error();
        } elseif (($this->_result instanceof mysqli_result)) {
            if ($type == "ASSOC") {
                while ($row = mysqli_fetch_assoc($this->_result)) {
                    $this->_lastResult[] = $row;
                }
            } else {
                while ($row = mysqli_fetch_object($this->_result)) {
                    $this->_lastResult[] = $row;
                }
            }

            mysqli_free_result($this->_result);
        }

        $stop = precision_timer('stop', $start);

        /**
         * After a query has successfully executed, that is it was considered
         * valid SQL, this delegate will provide the query, the query_hash and
         * the execution time of the query.
         *
         * Note that this function only starts logging once the ExtensionManager
         * is available, which means it will not fire for the first couple of
         * queries that set the character set.
         *
         * @since Symphony 2.3
         * @delegate PostQueryExecution
         * @param string $context
         * '/frontend/' or '/backend/'
         * @param string $query
         *  The query that has just been executed
         * @param string $query_hash
         *  The hash used by Symphony to uniquely identify this query
         * @param float $execution_time
         *  The time that it took to run `$query`
         */
        if (self::$_logging === true) {
            if (Symphony::ExtensionManager() instanceof ExtensionManager) {
                Symphony::ExtensionManager()->notifyMembers('PostQueryExecution', class_exists('Administration', false) ? '/backend/' : '/frontend/', array(
                    'query' => $query,
                    'query_hash' => $query_hash,
                    'execution_time' => $stop
                ));

                // If the ExceptionHandler is enabled, then the user is authenticated
                // or we have a serious issue, so log the query.
                if (GenericExceptionHandler::$enabled) {
                    self::$_log[$query_hash] = array(
                        'query' => $query,
                        'query_hash' => $query_hash,
                        'execution_time' => $stop
                    );
                }

                // Symphony isn't ready yet. Log internally
            } else {
                self::$_log[$query_hash] = array(
                    'query' => $query,
                    'query_hash' => $query_hash,
                    'execution_time' => $stop
                );
            }
        }

        return true;
    }

    /**
     * Returns the last insert ID from the previous query. This is
     * the value from an auto_increment field.
     *
     * @return integer
     *  The last interested row's ID
     */
    public function getInsertID()
    {
        return $this->_lastInsertID;
    }

    /**
     * If an error occurs in a query, this function is called which logs
     * the last query and the error number and error message from MySQL
     * before throwing a `DatabaseException`
     *
     * @uses QueryExecutionError
     * @throws DatabaseException
     * @param string $type
     *  Accepts one parameter, 'connect', which will return the correct
     *  error codes when the connection sequence fails
     */
    private function __error($type = null)
    {
        if ($type == 'connect') {
            $msg = mysqli_connect_error();
            $errornum = mysqli_connect_errno();
        } else {
            $msg = mysqli_error(self::$_connection['id']);
            $errornum = mysqli_errno(self::$_connection['id']);
        }

        /**
         * After a query execution has failed this delegate will provide the query,
         * query hash, error message and the error number.
         *
         * Note that this function only starts logging once the `ExtensionManager`
         * is available, which means it will not fire for the first couple of
         * queries that set the character set.
         *
         * @since Symphony 2.3
         * @delegate QueryExecutionError
         * @param string $context
         * '/frontend/' or '/backend/'
         * @param string $query
         *  The query that has just been executed
         * @param string $query_hash
         *  The hash used by Symphony to uniquely identify this query
         * @param string $msg
         *  The error message provided by MySQL which includes information on why the execution failed
         * @param integer $num
         *  The error number that corresponds with the MySQL error message
         */
        if (self::$_logging === true) {
            if (Symphony::ExtensionManager() instanceof ExtensionManager) {
                Symphony::ExtensionManager()->notifyMembers('QueryExecutionError', class_exists('Administration', false) ? '/backend/' : '/frontend/', array(
                    'query' => $this->_lastQuery,
                    'query_hash' => $this->_lastQueryHash,
                    'msg' => $msg,
                    'num' => $errornum
                ));
            }
        }

        throw new DatabaseException(__('MySQL Error (%1$s): %2$s in query: %3$s', array($errornum, $msg, $this->_lastQuery)), array(
            'msg' => $msg,
            'num' => $errornum,
            'query' => $this->_lastQuery
        ));
    }


}
