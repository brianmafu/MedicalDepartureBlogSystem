// User Controller
import { Request, Response } from  'express';
import { createUser, getUsers, getUserByEmail } from '../models/userModel.ts';
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import dotenv from 'dotenv';


dotenv.config()

export const RegisterUser = async (req: Request, res: Response) => {
 const { username, password } = req.body;
  const hashedPassword = await bcrypt.hash(password, 10);
  const user = {
	username,
	password: hashedPassword
  }
  try {
	const result = await createUser(user);
	res.status(201).json({ message: 'User created successfully', result });
  } catch (error) {
	res.status(500).json({ message: error.message });
  }
}

export const LoginUser = async (req: Request, res: Response) => {
	const { username, password } = req.body;
  try {
	const user = await getUserByEmail(username);
	if (user.length === 0) {
	  return res.status(400).json({ message: 'Invalid Credentials' });
	}
	const validPassword = await bcrypt.compare(password, user[0].password);
	if (!validPassword) {
	  return res.status(400).json({ message: 'Invalid Credentials' });
	}
	const token = jwt.sign({ id: user[0].id }, process.env.JWT_SECRET);
	res.status(200).json({ message: 'User logged in successfully', token });
  } catch (error) {
	res.status(500).json({ message: error.message });
  }
}