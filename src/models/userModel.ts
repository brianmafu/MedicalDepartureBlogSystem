import databasePool from "../config/database";

// User Interface
export interface User {
  id?: number;
  username: string;
  password: string;
}

// Create a new user
export const createUser = async(user: User) => {
	const result = await databasePool.query(
	'INSERT INTO Users (username, password) VALUES (?, ?)',
	[user.username, user.password]
  );
  return result[0];
}

// Get all users
export const getUsers = async() => {
	const result = await databasePool.query('SELECT * FROM Users');
	return result[0];
}

// get Users by Username
export const getUserByUsername = async (username: string): Promise<User[]> => {
  const [rows] = await databasePool.query('SELECT * FROM Users WHERE username = ?', [username]);
  return rows as User[];
};