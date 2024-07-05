import { databasePool } from "../config/database.ts";

// User Interface
interface User {
  id: number;
  username: string;
  password: string;
}

// Create a new user
export const createUser = async(user: User) => {
	const result = await databasePool.query(
	'INSERT INTO users (username, password) VALUES (?, ?)',
	[user.username, user.password]
  );
  return result[0];
}

// Get all users
export const getUsers = async() => {
	const result = await databasePool.query('SELECT * FROM users');
	return result[0];
}

# get Users by email
export const getUserByEmail = async(email: string) => {
	const result = await databasePool.query('SELECT * FROM users WHERE email = ?', [email]);
	return result[0];
}

