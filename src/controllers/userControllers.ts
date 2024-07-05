// User Controller
import { Request, Response } from  'express';
import { createUser, getUsers, getUserByUsername, User } from '../models/userModel';
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
  } catch (error: any) {
	res.status(500).json({ message: error.message });
  }
}

export const LoginUser = async (req: Request, res: Response) => {
  const { username, password } = req.body;
  try {
    const users = await getUserByUsername(username);
    if (users.length === 0) {
      return res.status(400).json({ message: 'Invalid Credentials' });
    }

    const user = users[0];
    const validPassword = await bcrypt.compare(password, user.password);
    if (!validPassword) {
      return res.status(400).json({ message: 'Invalid Credentials' });
    }

    if (!process.env.JWT_SECRET) {
      throw new Error('JWT_SECRET is not defined');
    }

    const token = jwt.sign({ id: user.id }, process.env.JWT_SECRET, { expiresIn: '1h' });
    res.status(200).json({ message: 'User logged in successfully', token });
  } catch (error: any) {
    res.status(500).json({ message: error.message });
  }
};