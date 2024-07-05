
import { Router } from 'express';

import { CreateBlog, GetBlogs, GetBlogById, UpdateBlogById, DeleteBlogById} from '../controllers/blogController';

const router = Router();
router.post('/create', CreateBlog);
router.get('/blogs', GetBlogs);
router.get('/:id', GetBlogById);
router.put('/:id', UpdateBlogById);
router.delete('/:id', DeleteBlogById);
export default router;